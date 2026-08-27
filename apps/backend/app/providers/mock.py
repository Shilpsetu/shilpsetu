"""Deterministic mock providers.

This is not a testing convenience. `PROVIDER_PROFILE=mock` must run the whole
listing flow with the network disabled -- it is what we fall back to when the
venue wifi dies mid-demo (ADR-0002). Keep it working.
"""

from __future__ import annotations

from decimal import Decimal

from app.providers.base import (
    Description,
    DescriptionWriter,
    EnhancedImage,
    ImageEnhancer,
    PriceEstimator,
    PriceQuote,
    ProductAttributes,
    ProviderStamp,
    SpeechTranscriber,
    Transcript,
    TranslatedText,
    Translator,
)

STAMP = ProviderStamp(provider="mock", model_version="fixture-1")

# A real Telugu sentence a Pochampally weaver might say, and its fixtures.
_FIXTURE_TRANSCRIPT = "ఇది చేతితో నేసిన పోచంపల్లి ఇకత్ చీర."


class MockTranscriber(SpeechTranscriber):
    async def transcribe(self, audio: bytes, *, language: str) -> Transcript:
        return Transcript(
            text=_FIXTURE_TRANSCRIPT,
            language=language,
            confidence=0.94,
            stamp=STAMP,
        )


class MockTranslator(Translator):
    async def translate(self, text: str, *, source: str, target: str) -> TranslatedText:
        return TranslatedText(
            text=f"[{target}] {text}",
            source_language=source,
            target_language=target,
            stamp=STAMP,
        )


class MockDescriptionWriter(DescriptionWriter):
    async def extract(self, transcript: Transcript) -> ProductAttributes:
        return ProductAttributes(
            craft_id="pochampally_ikat",
            product_type="saree",
            technique="handloom double ikat",
            materials=("cotton",),
            colours=("indigo",),
            dimensions="5.5 m with blouse piece",
            hours_to_make=None,  # deliberately missing -> spoken follow-up
            quantity_available=None,  # deliberately missing -> spoken follow-up
        )

    async def write(
        self,
        attributes: ProductAttributes,
        *,
        craft_vocabulary: tuple[str, ...],
        locales: tuple[str, ...],
    ) -> tuple[Description, ...]:
        bodies = {
            "en-IN": (
                "Handwoven Pochampally double-ikat cotton saree",
                "Handwoven Pochampally double-ikat cotton saree, natural indigo dye, "
                "5.5 m with blouse piece. Bhoodan Pochampally cluster, Telangana. "
                "GI-tagged handloom.",
            ),
            "hi-IN": (
                "हाथ से बुनी पोचमपल्ली डबल इकत सूती साड़ी",
                "हाथ से बुनी पोचमपल्ली डबल इकत सूती साड़ी, प्राकृतिक नील रंगाई, 5.5 मीटर।",
            ),
        }
        out = []
        for loc in locales:
            title, body = bodies.get(loc, (f"[{loc}] product", f"[{loc}] description"))
            out.append(
                Description(
                    locale=loc,
                    title=title,
                    body=body,
                    keywords=craft_vocabulary[:8],
                    stamp=STAMP,
                )
            )
        return tuple(out)


class MockImageEnhancer(ImageEnhancer):
    async def enhance(self, image: bytes, *, craft_id: str | None = None) -> EnhancedImage:
        return EnhancedImage(image=image, alpha_matte=None, width=1600, height=1600, stamp=STAMP)


class MockPriceEstimator(PriceEstimator):
    async def quote(
        self,
        attributes: ProductAttributes,
        *,
        craft_id: str,
        material_cost: Decimal,
        finish_score: float,
    ) -> PriceQuote:
        return PriceQuote(
            floor=Decimal("1850"),
            suggested=Decimal("2700"),
            stretch=Decimal("3200"),
            band_low=Decimal("2400"),
            band_high=Decimal("3200"),
            rationale=(
                "Your materials and eleven days of work come to Rs 1,850. "
                "Sarees like yours sell between Rs 2,400 and Rs 3,200. "
                "I suggest Rs 2,700."
            ),
            comparables_snapshot="fixture-2026-08",
            stamp=STAMP,
        )
