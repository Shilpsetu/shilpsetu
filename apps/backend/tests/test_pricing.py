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
    b = pricing.compute_floor(material_cost=Decimal("100"), hours=Decimal("88"), wage=wage)
    quote = pricing.build_quote(
        breakdown=b,
        band_low=Decimal("6000"),
        band_high=Decimal("9000"),
        finish_score=0.5,
    )
    assert "11 days" in quote.rationale
    # Nothing that a text-to-speech engine would read out as gibberish.
    assert "%" not in quote.rationale
    assert "_" not in quote.rationale
    assert "None" not in quote.rationale


class TestFloorAboveMarket:
    """The case that matters most: honest wages cost more than the market pays.

    Silently clamping the band here would hide the finding the app exists to
    surface, and would make the spoken rationale nonsense
    ("sells between 6552 and 6552 rupees").
    """

    @staticmethod
    def _breakdown(wage: pricing.WageBasis) -> pricing.FloorBreakdown:
        # 88 h of Pochampally weaving at Rs 450/day, Rs 900 of materials.
        return pricing.compute_floor(material_cost=Decimal("900"), hours=Decimal("88"), wage=wage)

    def test_band_is_reported_honestly_not_clamped(self, wage: pricing.WageBasis) -> None:
        q = pricing.build_quote(
            breakdown=self._breakdown(wage),
            band_low=Decimal("2400"),
            band_high=Decimal("3200"),
            finish_score=0.6,
        )
        assert q.position is pricing.MarketPosition.FLOOR_ABOVE_MARKET
        assert (q.band_low, q.band_high) == (Decimal("2400"), Decimal("3200"))
        assert q.band_low < q.band_high, "the band must not collapse to a point"

    def test_price_is_the_floor_never_the_market(self, wage: pricing.WageBasis) -> None:
        b = self._breakdown(wage)
        q = pricing.build_quote(
            breakdown=b,
            band_low=Decimal("2400"),
            band_high=Decimal("3200"),
            finish_score=0.6,
        )
        assert q.suggested == b.floor

    def test_rationale_names_the_shortfall_out_loud(self, wage: pricing.WageBasis) -> None:
        q = pricing.build_quote(
            breakdown=self._breakdown(wage),
            band_low=Decimal("2400"),
            band_high=Decimal("3200"),
            finish_score=0.6,
        )
        assert "less than your work is worth" in q.rationale
        assert "will not sell at a loss" in q.rationale

    def test_normal_case_still_prices_to_the_market(self, wage: pricing.WageBasis) -> None:
        cheap = pricing.compute_floor(material_cost=Decimal("100"), hours=Decimal("8"), wage=wage)
        q = pricing.build_quote(
            breakdown=cheap,
            band_low=Decimal("2400"),
            band_high=Decimal("3200"),
            finish_score=0.5,
        )
        assert q.position is pricing.MarketPosition.WITHIN_BAND
        assert Decimal("2400") <= q.suggested <= Decimal("3200")
        assert q.suggested > cheap.floor, "should capture market value, not just cost"

    def test_never_suggests_below_floor_even_in_a_weak_market(
        self, wage: pricing.WageBasis
    ) -> None:
        b = self._breakdown(wage)
        q = pricing.build_quote(
            breakdown=b,
            band_low=Decimal("1"),
            band_high=Decimal("999999"),
            finish_score=0.0,
        )
        assert q.suggested >= b.floor


@pytest.mark.parametrize(
    ("hours", "expected"),
    [(Decimal("8"), "1 day"), (Decimal("16"), "2 days"), (Decimal("88"), "11 days")],
)
def test_days_are_pluralised(hours: Decimal, expected: str, wage: pricing.WageBasis) -> None:
    """Everything here is read aloud. "1 days" is a bug, not a nit."""
    b = pricing.compute_floor(material_cost=Decimal("100"), hours=hours, wage=wage)
    q = pricing.build_quote(
        breakdown=b,
        band_low=Decimal("9000"),
        band_high=Decimal("9500"),
        finish_score=0.5,
    )
    assert f"{expected} of work" in q.rationale
