## What and why

<!-- One or two sentences. Link the issue: Closes #123 -->

## Definition of done

- [ ] Does what the issue asked
- [ ] Lint and types clean (`ruff` / `flutter analyze --fatal-infos`)
- [ ] Tests added or updated, and passing
- [ ] Works offline **if this feature claims to**
- [ ] Any user-visible string exists in `hi-IN` as well as `en-IN`
- [ ] Run once on the reference device (not just an emulator)

## The rules this must not break

- [ ] No typing added to the artisan's critical path (Bet 01)
- [ ] No generated file hand-edited (`packages/api_client_dart/`, `*.g.dart`)
- [ ] Business logic still imports the provider ABC, not a concrete provider
- [ ] `PROVIDER_PROFILE=mock` still runs the full flow with the network off
- [ ] Backend schema change? `./tools/gen_api.sh` run and the result committed
