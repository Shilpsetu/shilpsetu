"""The floor is the claim we defend on stage. Test it like it matters."""

from __future__ import annotations

from decimal import Decimal

import pytest
from app.domain import pricing


@pytest.fixture
def wage() -> pricing.WageBasis:
    return pricing.WageBasis(
        state="Telangana", daily_wage=Decimal("450"), source_ref="test-fixture"
    )


def test_floor_is_materials_plus_labour_plus_overhead(wage: pricing.WageBasis) -> None:
    b = pricing.compute_floor(
        material_cost=Decimal("900"),
        hours=Decimal("88"),
        wage=wage,
        overhead_rate=Decimal("0.12"),
    )
    # 88h at 450/8 = 56.25/h -> 4950 labour; +900 materials = 5850; +12% = 6552
    assert b.labour_cost == Decimal("4950")
    assert b.floor == Decimal("6552")
    assert b.material_cost + b.labour_cost < b.floor  # overhead is included


def test_floor_rejects_zero_hours(wage: pricing.WageBasis) -> None:
    with pytest.raises(ValueError, match="hours must be positive"):
        pricing.compute_floor(material_cost=Decimal("100"), hours=Decimal("0"), wage=wage)


def test_floor_rejects_negative_materials(wage: pricing.WageBasis) -> None:
    with pytest.raises(ValueError, match="material_cost"):
        pricing.compute_floor(material_cost=Decimal("-1"), hours=Decimal("8"), wage=wage)


@pytest.mark.parametrize(
    ("score", "expected"),
    [(0.0, Decimal("2480")), (0.5, Decimal("2800")), (1.0, Decimal("3120"))],
)
def test_band_position_is_compressed_to_middle_80_percent(score: float, expected: Decimal) -> None:
    """A finish score of 1.0 must NOT put an item at the very top of its band.

    The image model is not good enough to justify that claim, so we compress
    into the middle 80% deliberately.
    """
    got = pricing.position_in_band(
        band_low=Decimal("2400"), band_high=Decimal("3200"), finish_score=score
    )
    assert got == expected


def test_band_position_rejects_out_of_range_score() -> None:
    with pytest.raises(ValueError, match=r"\[0, 1\]"):
        pricing.position_in_band(band_low=Decimal("1"), band_high=Decimal("2"), finish_score=1.5)


def test_rationale_is_speakable(wage: pricing.WageBasis) -> None:
    b = pricing.compute_floor(material_cost=Decimal("900"), hours=Decimal("88"), wage=wage)
    text = pricing.speak_rationale(b, Decimal("2700"), Decimal("2400"), Decimal("3200"))
    assert "11 days" in text
    assert "%" not in text and "_" not in text  # nothing unspeakable slipped in
