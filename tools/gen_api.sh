#!/usr/bin/env bash
# Regenerate the API contract and the Dart client (ADR-0005).
#
#   ./tools/gen_api.sh
#
# Idempotent: run it, then `git status`. A clean tree means the contract did
# not move. A dirty tree means it did, and the diff is your review.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> exporting OpenAPI schema"
( cd "$REPO/apps/backend" && uv run python ../../tools/export_openapi.py )

echo "==> generating Dart client"
python3 "$REPO/tools/gen_dart_client.py"
