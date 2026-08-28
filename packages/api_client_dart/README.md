# karigar_api — generated

**Do not edit `lib/`.** It is generated from `openapi.json`, which is itself
generated from the FastAPI app. CI fails if either is stale (ADR-0005).

Regenerate after any backend schema change:

```bash
cd apps/backend && uv run python ../../tools/export_openapi.py
python tools/gen_dart_client.py
```

Both commands are idempotent, so `git status` after running them tells you
whether the contract actually moved.

## Why a hand-written generator

`openapi-generator` needs a JDK on every developer's machine and its
`dart-dio` output drags in `built_value`, which is a second code-generation
system for a team already learning freezed, riverpod and drift. Our API
surface is small and fully under our control, so `tools/gen_dart_client.py`
(about 250 lines, tested) emits exactly the Dart we want and runs in a second
with no extra toolchain.

It is deliberately **strict**: any schema shape it does not understand is a
hard error, never a silent `dynamic`. A generator that quietly emits the wrong
type is worse than no generator.
