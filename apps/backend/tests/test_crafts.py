from __future__ import annotations

import pytest
from app.domain.crafts import TulipCollection, get_craft, load_crafts


def test_seed_loads_and_every_collection_is_represented() -> None:
    crafts = load_crafts()
    assert len(crafts) >= 12
    covered = {c.collection for c in crafts.values()}
    assert covered == set(TulipCollection), "every TULIP collection needs seed crafts"


def test_every_craft_has_vocabulary() -> None:
    """Empty vocabulary means the writer falls back to generic adjectives,
    which is exactly the failure Bet 02 exists to prevent."""
    for craft in load_crafts().values():
        assert len(craft.vocabulary) >= 4, f"{craft.id} needs more craft-specific words"


def test_unknown_craft_raises() -> None:
    with pytest.raises(KeyError):
        get_craft("not_a_real_craft")
