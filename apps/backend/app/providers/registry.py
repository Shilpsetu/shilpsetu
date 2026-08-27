"""Config-driven provider selection (ADR-0002).

Adding a provider means adding one entry to the relevant table. Nothing that
imports a capability needs to change.
"""

from __future__ import annotations

from collections.abc import Callable
from typing import TypeVar

from app.config import Settings, get_settings
from app.providers import mock
from app.providers.base import (
    DescriptionWriter,
    ImageEnhancer,
    PriceEstimator,
    SpeechTranscriber,
    Translator,
)

T = TypeVar("T")

# capability -> provider name -> factory
_TRANSCRIBERS: dict[str, Callable[[Settings], SpeechTranscriber]] = {
    "mock": lambda _s: mock.MockTranscriber(),
}
_TRANSLATORS: dict[str, Callable[[Settings], Translator]] = {
    "mock": lambda _s: mock.MockTranslator(),
}
_WRITERS: dict[str, Callable[[Settings], DescriptionWriter]] = {
    "mock": lambda _s: mock.MockDescriptionWriter(),
}
_ENHANCERS: dict[str, Callable[[Settings], ImageEnhancer]] = {
    "mock": lambda _s: mock.MockImageEnhancer(),
}
_PRICERS: dict[str, Callable[[Settings], PriceEstimator]] = {
    "mock": lambda _s: mock.MockPriceEstimator(),
}


def _pick(table: dict[str, Callable[[Settings], T]], capability: str, settings: Settings) -> T:
    name = settings.resolve(capability)
    try:
        return table[name](settings)
    except KeyError:
        available = ", ".join(sorted(table))
        msg = (
            f"No {capability} provider named {name!r}. Available: {available}. "
            f"Check PROVIDER_PROFILE or PROVIDER_{capability.upper()} in your .env."
        )
        raise RuntimeError(msg) from None


def get_transcriber(settings: Settings | None = None) -> SpeechTranscriber:
    return _pick(_TRANSCRIBERS, "transcriber", settings or get_settings())


def get_translator(settings: Settings | None = None) -> Translator:
    return _pick(_TRANSLATORS, "translator", settings or get_settings())


def get_writer(settings: Settings | None = None) -> DescriptionWriter:
    return _pick(_WRITERS, "writer", settings or get_settings())


def get_enhancer(settings: Settings | None = None) -> ImageEnhancer:
    return _pick(_ENHANCERS, "enhancer", settings or get_settings())


def get_pricer(settings: Settings | None = None) -> PriceEstimator:
    return _pick(_PRICERS, "pricer", settings or get_settings())
