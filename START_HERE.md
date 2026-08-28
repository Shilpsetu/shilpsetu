# Start here

Find your name. Everything you need is in your section: the exact folders you
own, the commands to get running, and your first three tasks.

**Two rules that apply to everyone:**

1. **Only edit files inside your own folders.** If you need something in
   someone else's, ask them for it — don't reach in. This is enforced by
   `.github/CODEOWNERS`.
2. **You are not blocked by anyone.** The backend already returns real data
   with no credentials and no network. Start today.

| Role | Person | Your folders | Jump to |
|---|---|---|---|
| Lead | Aditya | the seams | [↓](#lead--aditya) |
| App dev A | | `features/capture`, `features/enquiries`, `lib/ml` | [↓](#app-dev-a--camera-on-device-ml-enquiries) |
| App dev B | | `features/cataloger`, `catalog`, `pricing`, `l10n` | [↓](#app-dev-b--voice-catalog-pricing-language) |
| Backend | | `apps/backend`, `infra` | [↓](#backend) |
| ML | | `packages/ml`, `app/providers` | [↓](#ml) |
| Design + data | | `docs/design`, `infra/seeds`, `buyer_portal` | [↓](#design--data) |

> Fill in the names above and the handles in `.github/CODEOWNERS`, then run
> `./tools/check_setup.sh`.

---

## Everyone: get the backend running first (2 minutes)

You need this whatever your role — it is how you see real data.

```bash
git clone <this repo> && cd shilpsetu
cd apps/backend
uv sync                      # installs Python 3.12 if you don't have it
cp .env.example .env         # no keys needed, the defaults work
uv run pytest                # 25 tests, all green
uv run uvicorn app.main:app --reload
```

Open <http://localhost:8000/docs> and press "Try it out" on
`POST /v1/catalog/from-voice`. You will get back a Telugu transcript, extracted
attributes, and English + Hindi descriptions.

That is fixture data from the mock providers, **and the shapes are final**. Build
against them.

Don't have `uv`? → <https://docs.astral.sh/uv/getting-started/installation/>

---

## Lead — Aditya

**You own the seams.** You are deliberately not on any feature's critical path,
because you are the person who unblocks everyone else.

**Your folders:** `packages/api_client_dart/`, `tools/`, `docs/adr/`, `.github/`

**First three**
1. Confirm the roster — six from one institution, at least one female member,
   mentors named. **This gates the internal-round entry, so do it first.**
2. Buy the reference device (₹7,000, 2 GB RAM Android). Every performance claim
   we make is unverifiable until it is on a desk.
3. Start Bhashini registration (<https://bhashini.gitbook.io/bhashini-apis>).
   Government onboarding queues do not go faster because you need them later.

**Then:** fill in `.github/CODEOWNERS`, run `./tools/seed_issues.sh` to create
everyone's issues, and hold the 14 September scope freeze.

---

## App dev A — camera, on-device ML, enquiries

**Your folders**
- `apps/mobile/lib/features/capture/`
- `apps/mobile/lib/features/enquiries/`
- `apps/mobile/lib/ml/`

**Setup**
```bash
cd apps/mobile
flutter create . --platforms=android,ios --org in.shilpsetu
flutter pub get
flutter run
```
`flutter create` generates the native folders without touching `lib/`.

**First three**
1. Camera preview running on the reference device, respecting
   `Sizes.minTouchTarget` (64dp) from `lib/core/theme/tokens.dart`.
2. Get *any* U-2-Net-lite TFLite checkpoint running in an isolate. **Do not
   wait for ML's tuned model.** Prove the plumbing and measure the latency now;
   swap the weights later. Report the milliseconds — if 1.5 s is unreachable,
   this is the week to find out, not December.
3. The pre-shutter quality gate: refuse blur and backlight *before* the shutter
   fires, and say why aloud.

**You unblock:** the first thirty seconds of the demo.
**Blocked by:** nobody.

---

## App dev B — voice, catalog, pricing, language

**Your folders**
- `apps/mobile/lib/features/cataloger/`
- `apps/mobile/lib/features/catalog/`
- `apps/mobile/lib/features/pricing/`
- `apps/mobile/lib/l10n/`

**Setup:** same as App dev A above (whoever runs `flutter create` first commits it).

**Calling the API** — already wired for you:
```dart
final api = ref.watch(apiProvider);          // lib/core/api/api_provider.dart
final result = await api.catalogFromVoice(
  TranscribeIn(language: 'hi-IN', audioBase64: encoded),
);
for (final d in result.descriptions) { print('${d.locale}: ${d.title}'); }

// The API tells you exactly what to ask about next, in order:
result.attributes.missing;   // ['hours_to_make', 'quantity_available']
```

**First three**
1. Audio capture and playback; TTS speaking Hindi on a real device.
2. ARB files with `hi-IN` and `en-IN`. The analyzer fails the build on a
   missing string — that is deliberate.
3. Record → send → show attributes → ask the missing fields aloud, one question
   at a time.

**Note on prices:** money is `Decimal`, never `double`. Format for display;
never do arithmetic in floating point on rupees.

**You unblock:** the next sixty seconds of the demo.
**Blocked by:** nobody — the endpoints already return your shapes.

---

## Backend

**Your folders:** `apps/backend/`, `infra/`

**Setup**
```bash
cd apps/backend && uv sync && cp .env.example .env
docker compose -f ../../infra/docker-compose.yml up -d
uv run uvicorn app.main:app --reload
```

**First three**
1. Postgres schema + first Alembic migration for the eleven tables in the plan.
2. Media upload to MinIO. The original capture is **immutable** — every
   processing step must be re-runnable without asking the artisan to
   re-photograph.
3. Seed loader for `infra/seeds/crafts.json` and `wages.json`.

**If you change any Pydantic schema, run `./tools/gen_api.sh` and commit the
result.** CI fails otherwise, on purpose (ADR-0005).

**Yours in Phase 3:** the TULIP, ONDC and GeM exporters. Read the plan's
market-linkage section *before* designing the product tables, so the export
shapes don't surprise you in November.

---

## ML

**Your folders:** `packages/ml/`, `apps/backend/app/providers/`

**How this works:** every AI capability is an interface in
`app/providers/base.py` with a working mock. You replace one mock at a time.
Nothing else in the codebase should need to change — **if it does, the
interface is wrong and we fix the interface, not the callers** (ADR-0002).

**First three**
1. Replace `MockTranscriber` with a Bhashini implementation. Register it in
   `providers/registry.py`; switch with `PROVIDER_TRANSCRIBER=bhashini`.
2. Baseline the segmentation checkpoint App dev A is using, and start tuning.
3. Real `DescriptionWriter`: extraction into `ProductAttributes`, then
   craft-conditioned generation using each craft's `vocabulary` from
   `infra/seeds/crafts.json`. **Generic adjectives are the bug** — "blue cloth"
   about a double-ikat saree means Bet 02 has failed.

**Rule:** anything a model produced carries a `ProviderStamp`. A price or
description we cannot reproduce is one we will not show an artisan.

---

## Design + data

**Your folders:** `docs/design/`, `infra/seeds/`, `apps/buyer_portal/`

**Yours is the most underrated job on the team.** Both app developers build
against your design system, so it blocks them if it is late.

**First three**
1. The zero-literacy design system: icon set, colour semantics, touch targets,
   spoken-prompt patterns. Start from `apps/mobile/lib/core/theme/tokens.dart`
   — the constraints are already encoded there.
2. Verify `infra/seeds/crafts.json`. Every GI claim goes to the
   [GI Registry](https://search.ipindia.gov.in/GIRPublic/); `kantha_stitch` is
   marked unverified on purpose. Wrong craft vocabulary makes a generated
   description *confidently* wrong, which a buyer spots before we do.
3. Fill `infra/seeds/wages.json` with real notifications and real `source_ref`
   values. **A wage figure we cannot cite is one we cannot defend on stage** —
   and the fair-wage floor is our strongest impact claim.

---

## When you're stuck

| Question | Answer lives in |
|---|---|
| What am I building this week? | your section above, and `docs/WORKLOAD.md` |
| Why is it built this way? | `docs/adr/` |
| What is the whole plan? | `docs/shilpsetu-plan-v1.html` — open in a browser |
| Is my PR ready? | `.github/pull_request_template.md` |
| How do I run things? | `apps/backend/README.md`, `apps/mobile/README.md` |
