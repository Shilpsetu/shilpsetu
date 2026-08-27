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


def speak_rationale(
    breakdown: FloorBreakdown, suggested: Decimal, band_low: Decimal, band_high: Decimal
) -> str:
    """Plain language, short sentences, no jargon -- this gets read aloud."""
    days = (breakdown.hours / Decimal("8")).quantize(Decimal("1"), rounding=ROUND_HALF_UP)
    return (
        f"Your materials and {days} days of work come to {breakdown.floor} rupees. "
        f"Items like yours sell between {band_low} and {band_high} rupees. "
        f"I suggest {suggested} rupees."
    )
