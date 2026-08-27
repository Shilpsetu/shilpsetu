"""The fair-wage price floor (Bet 03).

We do not output one confident number from a model we cannot defend. We output
a floor we can show our working for, a band from craft-matched comparables,
and the gap between them.

The floor is deliberately simple arithmetic. That is a feature: every number
an artisan hears must be explainable back to her, and 'the model said so' is
not an explanation.
"""

from __future__ import annotations

from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal
from enum import StrEnum

# Rounding for anything an artisan will hear spoken aloud.
_RUPEE = Decimal("1")


def _rupees(value: Decimal) -> Decimal:
    return value.quantize(_RUPEE, rounding=ROUND_HALF_UP)


@dataclass(frozen=True, slots=True)
class WageBasis:
    """Fair-wage inputs for one state.

    `daily_wage` should be sourced from the applicable state handloom /
    handicraft minimum wage notification and carry the notification reference,
    so a judge -- or an artisan -- can check it.
    """

    state: str
    daily_wage: Decimal
    hours_per_day: Decimal = Decimal("8")
    source_ref: str = ""

    @property
    def hourly_wage(self) -> Decimal:
        return self.daily_wage / self.hours_per_day


@dataclass(frozen=True, slots=True)
class FloorBreakdown:
    """Every component, kept separate so the rationale can be spoken."""

    material_cost: Decimal
    labour_cost: Decimal
    overhead: Decimal
    floor: Decimal
    hours: Decimal
    hourly_wage: Decimal


def compute_floor(
    *,
    material_cost: Decimal,
    hours: Decimal,
    wage: WageBasis,
    overhead_rate: Decimal = Decimal("0.12"),
) -> FloorBreakdown:
    """Materials + hours at fair wage + overhead.

    `overhead_rate` covers loom maintenance, dye, transport to the cluster
    centre and packaging. 12% is a placeholder to be replaced with a
    cluster-surveyed figure before we quote it publicly.
    """
    if material_cost < 0:
        msg = "material_cost cannot be negative"
        raise ValueError(msg)
    if hours <= 0:
        msg = "hours must be positive -- ask the artisan again"
        raise ValueError(msg)

    labour = hours * wage.hourly_wage
    subtotal = material_cost + labour
    overhead = subtotal * overhead_rate

    return FloorBreakdown(
        material_cost=_rupees(material_cost),
        labour_cost=_rupees(labour),
        overhead=_rupees(overhead),
        floor=_rupees(subtotal + overhead),
        hours=hours,
        hourly_wage=_rupees(wage.hourly_wage),
    )


def position_in_band(
    *,
    band_low: Decimal,
    band_high: Decimal,
    finish_score: float,
) -> Decimal:
    """Place an item inside its craft's comparables band by finish quality.

    `finish_score` is 0..1 from the image model (weave regularity, edge finish,
    colour saturation). We deliberately compress it into the middle 80% of the
    band: the image model is not good enough to justify claiming an item is at
    the very top or bottom of its market.
    """
    if not 0.0 <= finish_score <= 1.0:
        msg = f"finish_score must be in [0, 1], got {finish_score}"
        raise ValueError(msg)
    if band_high < band_low:
        msg = "band_high must be >= band_low"
        raise ValueError(msg)

    compressed = Decimal("0.10") + Decimal(str(finish_score)) * Decimal("0.80")
    return _rupees(band_low + (band_high - band_low) * compressed)


class MarketPosition(StrEnum):
    """Where the fair-wage floor sits relative to what the market pays."""

    WITHIN_BAND = "within_band"
    """Normal case: the floor is at or below what comparable items fetch."""

    FLOOR_ABOVE_MARKET = "floor_above_market"
    """The floor exceeds the whole comparables band.

    This is not an error and must never be smoothed away. It means that at an
    honest wage this item costs more to make than similar items sell for --
    which is the single most useful thing we can tell an artisan, and the
    single most useful thing we can aggregate for the Ministry. Hiding it by
    clamping the band would make us complicit in the underpricing this app
    exists to stop.
    """


@dataclass(frozen=True, slots=True)
class Quote:
    breakdown: FloorBreakdown
    band_low: Decimal
    """True comparables band. Never clamped to the floor."""
    band_high: Decimal
    suggested: Decimal
    stretch: Decimal
    position: MarketPosition
    rationale: str


def build_quote(
    *,
    breakdown: FloorBreakdown,
    band_low: Decimal,
    band_high: Decimal,
    finish_score: float,
) -> Quote:
    """Compose a quote, keeping the comparables band honest.

    We never suggest below the floor, and we never pretend the band is
    something it is not. When those two rules conflict, we say so out loud.
    """
    if band_high < band_low:
        msg = "band_high must be >= band_low"
        raise ValueError(msg)

    market_price = position_in_band(
        band_low=band_low, band_high=band_high, finish_score=finish_score
    )

    if breakdown.floor > band_high:
        return Quote(
            breakdown=breakdown,
            band_low=band_low,
            band_high=band_high,
            suggested=breakdown.floor,
            stretch=breakdown.floor,
            position=MarketPosition.FLOOR_ABOVE_MARKET,
            rationale=_speak_floor_above_market(breakdown, band_low, band_high),
        )

    suggested = max(market_price, breakdown.floor)
    return Quote(
        breakdown=breakdown,
        band_low=band_low,
        band_high=band_high,
        suggested=suggested,
        stretch=max(band_high, suggested),
        position=MarketPosition.WITHIN_BAND,
        rationale=_speak_within_band(breakdown, suggested, band_low, band_high),
    )


def _days(hours: Decimal) -> str:
    """Whole days, pluralised. This string is spoken aloud, so "1 days" is a bug."""
    count = (hours / Decimal("8")).quantize(Decimal("1"), rounding=ROUND_HALF_UP)
    return f"{count} day" if count == 1 else f"{count} days"


def _speak_within_band(
    breakdown: FloorBreakdown, suggested: Decimal, band_low: Decimal, band_high: Decimal
) -> str:
    """Plain language, short sentences, no jargon -- this gets read aloud."""
    return (
        f"Your materials and {_days(breakdown.hours)} of work come to "
        f"{breakdown.floor} rupees. Items like yours sell between {band_low} and "
        f"{band_high} rupees. I suggest {suggested} rupees."
    )


def _speak_floor_above_market(
    breakdown: FloorBreakdown, band_low: Decimal, band_high: Decimal
) -> str:
    """Say the hard thing plainly. Do not soften it into meaninglessness."""
    return (
        f"Your materials and {_days(breakdown.hours)} of work come to "
        f"{breakdown.floor} rupees. Items like yours are selling for only "
        f"{band_low} to {band_high} rupees. That is less than your work is worth. "
        f"I have set your price at {breakdown.floor} rupees. "
        f"It may sell slowly, but it will not sell at a loss."
    )
