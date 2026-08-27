from __future__ import annotations

import base64
from decimal import Decimal

from fastapi import APIRouter, HTTPException

from app.api.v1 import schemas
from app.domain import pricing
from app.domain.crafts import get_craft, load_crafts
from app.providers import registry
from app.providers.base import ProductAttributes

router = APIRouter(prefix="/v1")

# Fields the cataloger asks about, in the order it should ask.
REQUIRED_ATTRIBUTES = (
    "craft_id",
    "product_type",
    "materials",
    "hours_to_make",
    "quantity_available",
)


@router.get("/health", tags=["ops"])
async def health() -> dict[str, str]:
    return {"status": "ok"}


@router.get("/crafts", response_model=list[schemas.CraftOut], tags=["catalog"])
async def list_crafts() -> list[schemas.CraftOut]:
    return [
        schemas.CraftOut(
            id=c.id,
            name=c.name,
            collection=c.collection.value,
            state=c.state,
            cluster=c.cluster,
            gi_tagged=c.gi_tagged,
            unit=c.unit,
        )
        for c in load_crafts().values()
    ]


@router.post("/catalog/from-voice", response_model=schemas.CatalogOut, tags=["catalog"])
async def catalog_from_voice(payload: schemas.TranscribeIn) -> schemas.CatalogOut:
    """Voice note in, structured listing out.

    The transcript is never handed to the writer as free text -- it is
    extracted into a typed schema first, so missing fields become spoken
    follow-up questions rather than model invention.
    """
    try:
        audio = base64.b64decode(payload.audio_base64, validate=True)
    except (ValueError, TypeError) as exc:
        raise HTTPException(status_code=422, detail="audio_base64 is not valid base64") from exc

    transcript = await registry.get_transcriber().transcribe(audio, language=payload.language)
    attributes = await registry.get_writer().extract(transcript)

    vocabulary: tuple[str, ...] = ()
    if attributes.craft_id:
        try:
            vocabulary = get_craft(attributes.craft_id).vocabulary
        except KeyError:
            vocabulary = ()

    descriptions = await registry.get_writer().write(
        attributes, craft_vocabulary=vocabulary, locales=("en-IN", "hi-IN")
    )

    return schemas.CatalogOut(
        transcript=transcript.text,
        language=transcript.language,
        attributes=schemas.AttributesOut(
            craft_id=attributes.craft_id,
            product_type=attributes.product_type,
            technique=attributes.technique,
            materials=list(attributes.materials),
            colours=list(attributes.colours),
            dimensions=attributes.dimensions,
            hours_to_make=attributes.hours_to_make,
            quantity_available=attributes.quantity_available,
            missing=list(attributes.missing(REQUIRED_ATTRIBUTES)),
        ),
        descriptions=[
            schemas.DescriptionOut(
                locale=d.locale, title=d.title, body=d.body, keywords=list(d.keywords)
            )
            for d in descriptions
        ],
    )


@router.post("/pricing/quote", response_model=schemas.PriceOut, tags=["pricing"])
async def quote(payload: schemas.PriceIn) -> schemas.PriceOut:
    """Floor, band and suggestion -- never one opaque number (Bet 03)."""
    try:
        craft = get_craft(payload.craft_id)
    except KeyError as exc:
        raise HTTPException(status_code=404, detail=f"Unknown craft {payload.craft_id}") from exc

    # TODO(ml): load from infra/seeds/wages.json once notifications are cited.
    wage = pricing.WageBasis(
        state=payload.state,
        daily_wage=Decimal("450"),
        source_ref="PLACEHOLDER -- see infra/seeds/README.md",
    )

    try:
        breakdown = pricing.compute_floor(
            material_cost=payload.material_cost, hours=payload.hours, wage=wage
        )
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc

    attributes = ProductAttributes(
        craft_id=craft.id,
        materials=craft.materials,
        hours_to_make=float(payload.hours),
    )
    estimate = await registry.get_pricer().quote(
        attributes,
        craft_id=craft.id,
        material_cost=payload.material_cost,
        finish_score=payload.finish_score,
    )

    band_low = max(estimate.band_low, breakdown.floor)
    band_high = max(estimate.band_high, band_low)
    suggested = pricing.position_in_band(
        band_low=band_low, band_high=band_high, finish_score=payload.finish_score
    )

    return schemas.PriceOut(
        floor=breakdown.floor,
        suggested=suggested,
        stretch=band_high,
        band_low=band_low,
        band_high=band_high,
        rationale=pricing.speak_rationale(breakdown, suggested, band_low, band_high),
        material_cost=breakdown.material_cost,
        labour_cost=breakdown.labour_cost,
        overhead=breakdown.overhead,
    )
