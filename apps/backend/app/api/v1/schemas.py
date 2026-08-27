"""Wire schemas. These generate the OpenAPI contract, which generates the Dart
client (ADR-0005). Renaming a field here breaks the app -- do it deliberately.
"""

from __future__ import annotations

from decimal import Decimal

from pydantic import BaseModel, Field


class CraftOut(BaseModel):
    id: str
    name: str
    collection: str
    state: str
    cluster: str
    gi_tagged: bool
    unit: str


class TranscribeIn(BaseModel):
    language: str = Field(examples=["te-IN", "hi-IN"])
    audio_base64: str


class AttributesOut(BaseModel):
    craft_id: str | None = None
    product_type: str | None = None
    technique: str | None = None
    materials: list[str] = []
    colours: list[str] = []
    dimensions: str | None = None
    hours_to_make: float | None = None
    quantity_available: int | None = None
    missing: list[str] = Field(
        default=[],
        description="Fields still unfilled, in the order the app should ask about them aloud.",
    )


class DescriptionOut(BaseModel):
    locale: str
    title: str
    body: str
    keywords: list[str]


class CatalogOut(BaseModel):
    transcript: str
    language: str
    attributes: AttributesOut
    descriptions: list[DescriptionOut]


class PriceIn(BaseModel):
    craft_id: str
    state: str
    material_cost: Decimal
    hours: Decimal
    finish_score: float = Field(ge=0.0, le=1.0, default=0.5)


class PriceOut(BaseModel):
    currency: str = "INR"
    floor: Decimal
    suggested: Decimal
    stretch: Decimal
    band_low: Decimal
    band_high: Decimal
    position: str = Field(
        description=(
            "'within_band' or 'floor_above_market'. When floor_above_market, the "
            "app must show the below-market state explicitly (Palette.belowFloor "
            "plus icon plus speech) -- never just the number."
        )
    )
    rationale: str = Field(description="Plain language, for text-to-speech. Read this aloud.")
    material_cost: Decimal
    labour_cost: Decimal
    overhead: Decimal
