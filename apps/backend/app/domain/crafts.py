"""The craft taxonomy -- the spine of the system (Bet 02).

Every downstream decision conditions on the craft: segmentation strategy,
description vocabulary, SEO keywords, and which comparables the pricing engine
is allowed to look at.

The top level is *Bharat TULIP's own four collections*, not a taxonomy we
invented, so an export drops straight onto the shelf the Ministry already
runs.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from decimal import Decimal
from enum import StrEnum
from functools import lru_cache
from pathlib import Path


def _find_seed(name: str) -> Path:
    """Walk up from this file until we find infra/seeds/<name>.

    Hard-coding a parent count breaks the moment anyone moves a directory, and
    it breaks silently at import time. Fail loudly with a path instead.
    """
    here = Path(__file__).resolve()
    for parent in here.parents:
        candidate = parent / "infra" / "seeds" / name
        if candidate.is_file():
            return candidate
    msg = f"Could not find infra/seeds/{name} above {here}. Is the repo laid out correctly?"
    raise FileNotFoundError(msg)


SEED_PATH = _find_seed("crafts.json")


class TulipCollection(StrEnum):
    """Bharat TULIP's four curated collections."""

    VIRASAT_LIVING = "virasat_living"  # home decor
    RATNA_REKHA = "ratna_rekha"  # jewellery
    RESHAM_SUTRA = "resham_sutra"  # textiles
    LEATHER_LEGACY = "leather_legacy"  # leather goods


@dataclass(frozen=True, slots=True)
class Craft:
    id: str
    name: str
    collection: TulipCollection
    state: str
    cluster: str
    gi_tagged: bool
    unit: str
    materials: tuple[str, ...]
    vocabulary: tuple[str, ...]
    """Craft-specific words the description writer may use. This is what stops
    the model writing 'blue cloth' about a double-ikat saree."""
    typical_hours: float
    """Median hours of work, used to sanity-check a spoken estimate."""
    material_cost_hint: Decimal
    """Rough materials cost for one unit, in INR. A prompt, never a default."""


@lru_cache
def load_crafts() -> dict[str, Craft]:
    raw = json.loads(SEED_PATH.read_text(encoding="utf-8"))
    crafts: dict[str, Craft] = {}
    for row in raw:
        crafts[row["id"]] = Craft(
            id=row["id"],
            name=row["name"],
            collection=TulipCollection(row["collection"]),
            state=row["state"],
            cluster=row["cluster"],
            gi_tagged=row["gi_tagged"],
            unit=row["unit"],
            materials=tuple(row["materials"]),
            vocabulary=tuple(row["vocabulary"]),
            typical_hours=row["typical_hours"],
            material_cost_hint=Decimal(str(row["material_cost_hint"])),
        )
    return crafts


def get_craft(craft_id: str) -> Craft:
    try:
        return load_crafts()[craft_id]
    except KeyError:
        msg = f"Unknown craft {craft_id!r}"
        raise KeyError(msg) from None
