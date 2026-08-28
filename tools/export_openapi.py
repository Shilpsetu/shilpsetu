"""Export the OpenAPI schema from the FastAPI app (ADR-0005).

The schema is the contract. It is committed so that a change to it shows up as
a reviewable diff, and so CI can fail when the generated Dart client no longer
matches it.

    uv run python ../../tools/export_openapi.py      # from apps/backend
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
OUT = REPO / "packages" / "api_client_dart" / "openapi.json"


def main() -> int:
    sys.path.insert(0, str(REPO / "apps" / "backend"))
    from app.main import app  # noqa: PLC0415  (import after sys.path fix)

    schema = app.openapi()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    # sort_keys keeps the diff stable across runs and machines.
    OUT.write_text(
        json.dumps(schema, indent=2, sort_keys=True, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(f"wrote {OUT.relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
