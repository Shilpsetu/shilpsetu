#!/usr/bin/env bash
# Verify the repo is actually ready for six people to start.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
fail=0
note() { echo "  ✗ $1"; fail=1; }
ok()   { echo "  ✓ $1"; }

echo "Team setup"
if grep -qE '@(LEAD|APPDEV-A|APPDEV-B|BACKEND|MLDEV|DESIGNDATA)\b' .github/CODEOWNERS; then
  note "CODEOWNERS still has placeholder handles — review routing is doing nothing"
else ok "CODEOWNERS has real handles"; fi

if grep -q "^| App dev A | |" START_HERE.md; then
  note "START_HERE.md routing table has no names in it"
else ok "START_HERE.md names filled in"; fi

echo "Secrets"
if git ls-files | grep -qE '(^|/)\.env$'; then note ".env is tracked — remove it"; else ok "no .env tracked"; fi

echo "Contract"
if [[ -f packages/api_client_dart/openapi.json && -f packages/api_client_dart/lib/karigar_api.dart ]]; then
  ok "API contract and Dart client are committed"
else note "run ./tools/gen_api.sh"; fi

echo
[[ $fail == 0 ]] && echo "Ready." || echo "Fix the ✗ items above."
exit $fail
