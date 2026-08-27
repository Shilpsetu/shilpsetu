"""Provider interfaces (ADR-0002).

Business logic imports from this module and never from a concrete provider.
Every type here is expressed in *our* domain vocabulary -- a vendor's field
name appearing in one of these signatures is a review blocker.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from decimal import Decimal


@dataclass(frozen=True, slots=True)
class ProviderStamp:
    """Provenance for anything a model produced. Never optional.

    If we cannot say which provider and which model version produced a
    description or a price, we cannot reproduce it, and an unreproducible
    price suggestion is not one we are willing to show an artisan.
    """

    provider: str
    model_version: str


@dataclass(frozen=True, slots=True)
class Transcript:
    text: str
    language: str  # BCP-47, e.g. "te-IN"
    confidence: float
    stamp: ProviderStamp


@dataclass(frozen=True, slots=True)
class TranslatedText:
    text: str
    source_language: str
    target_language: str
    stamp: ProviderStamp


@dataclass(frozen=True, slots=True)
class ProductAttributes:
    """The typed output of extraction.

    The transcript is never handed to the description writer as free text.
    Unfilled fields become spoken follow-up questions -- that is the whole
    point of this being a schema rather than a paragraph.
    """

    craft_id: str | None = None
    product_type: str | None = None
    technique: str | None = None
    materials: tuple[str, ...] = ()
    colours: tuple[str, ...] = ()
    dimensions: str | None = None
    hours_to_make: float | None = None
    quantity_available: int | None = None

    def missing(self, required: tuple[str, ...]) -> tuple[str, ...]:
        """Fields the cataloger still needs to ask about, in ask-order."""
        return tuple(f for f in required if not getattr(self, f, None))


@dataclass(frozen=True, slots=True)
class Description:
    locale: str  # "en-IN", "hi-IN"
    title: str
    body: str
    keywords: tuple[str, ...]
    stamp: ProviderStamp


@dataclass(frozen=True, slots=True)
class EnhancedImage:
    image: bytes
    alpha_matte: bytes | None
    width: int
    height: int
    stamp: ProviderStamp


@dataclass(frozen=True, slots=True)
class PriceQuote:
    """Three numbers and a spoken reason -- never one opaque number.

    `floor` is arithmetic we can show our working for: materials plus hours at
    the state fair-wage rate. `band_low`/`band_high` are craft-matched
    comparables. We do not publish below `floor`.
    """

    floor: Decimal
    suggested: Decimal
    stretch: Decimal
    band_low: Decimal
    band_high: Decimal
    currency: str = "INR"
    rationale: str = ""
    comparables_snapshot: str = ""
    stamp: ProviderStamp = field(default=ProviderStamp("unset", "0"))

    def __post_init__(self) -> None:
        if self.suggested < self.floor:
            msg = f"suggested {self.suggested} is below floor {self.floor}"
            raise ValueError(msg)


# --- Interfaces --------------------------------------------------------------


class SpeechTranscriber(ABC):
    @abstractmethod
    async def transcribe(self, audio: bytes, *, language: str) -> Transcript: ...


class Translator(ABC):
    @abstractmethod
    async def translate(self, text: str, *, source: str, target: str) -> TranslatedText: ...


class DescriptionWriter(ABC):
    @abstractmethod
    async def extract(self, transcript: Transcript) -> ProductAttributes: ...

    @abstractmethod
    async def write(
        self,
        attributes: ProductAttributes,
        *,
        craft_vocabulary: tuple[str, ...],
        locales: tuple[str, ...],
    ) -> tuple[Description, ...]: ...


class ImageEnhancer(ABC):
    @abstractmethod
    async def enhance(self, image: bytes, *, craft_id: str | None = None) -> EnhancedImage: ...


class PriceEstimator(ABC):
    @abstractmethod
    async def quote(
        self,
        attributes: ProductAttributes,
        *,
        craft_id: str,
        material_cost: Decimal,
        finish_score: float,
    ) -> PriceQuote: ...
