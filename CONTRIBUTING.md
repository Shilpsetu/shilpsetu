# Working on Shilpsetu

## Before your first push

```bash
git config core.autocrlf input      # Windows only
cd apps/backend && uv sync && cp .env.example .env
cd ../mobile && flutter pub get
```

## Branching

Trunk-based. Branch off `main`, keep it **under 48 hours**, open a PR.

```
feat/capture-quality-gate
fix/sync-outbox-duplicate
docs/adr-0007-media-variants
```

Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.

## Definition of done

A PR is not done until all of these are true:

- [ ] Merged behaviour matches what the issue asked for
- [ ] Lint and types clean (`ruff` / `flutter analyze`)
- [ ] Tests added or updated, and passing
- [ ] Works offline **if the feature claims to**
- [ ] Any user-visible string exists in `hi-IN` as well as `en-IN`
- [ ] Run once on the reference device — not just an emulator

"Works on my emulator" is not done. The ₹7,000 Android phone on the desk is
the target; a flagship is not.

## Rules that are not negotiable

1. **No typing on the artisan's critical path.** If your feature requires a
   keyboard to complete a listing, it is wrong. Voice, camera, or tap.
2. **Never edit generated files.** `packages/api_client_dart/`, `*.g.dart`,
   `*.freezed.dart` are outputs. Change the source and regenerate.
3. **Business logic imports the provider ABC, never a concrete provider.**
   (ADR-0002)
4. **`app/domain/` imports nothing from FastAPI or SQLAlchemy.** (ADR-0006)
5. **`PROVIDER_PROFILE=mock` must always run the full flow with the network
   off.** If your change breaks that, you have broken our demo insurance.
6. **Every schema change gets an Alembic migration.** No manual DDL, ever.
7. **A price we cannot explain aloud does not ship.** (Bet 03)

## Decisions

Anything expensive to reverse goes in `docs/adr/` as a PR before the code
lands. Context, decision, consequences — and the consequences must name the
cost we accepted, not only the benefit.
