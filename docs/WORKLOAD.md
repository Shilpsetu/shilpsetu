# Workload — Phase 0 and Phase 1

Six people. Phase 0 ends **2 September**, Phase 1 (the walking skeleton, and
the internal-round demo) ends **14 September**. Scope freezes on the 14th.

## The rule that prevents merge hell

**Feature folders are ownership boundaries.** Two people never edit the same
file in the same week. The split below is by *feature*, not by layer,
precisely so that the two app developers never touch the same widget.

If you need something inside someone else's folder, you do not reach in — you
ask them for an interface and code against it.

## Everyone is already unblocked

The scaffold ships with **working mock providers**, so nobody is waiting on
anybody:

- The app developers can call `POST /v1/catalog/from-voice` today and get a
  real transcript, real attributes and English + Hindi descriptions back. It
  is fixture data, but the shape is final.
- The ML developer can replace one provider at a time behind a stable
  interface without breaking the app.
- `POST /v1/pricing/quote` already returns a real fair-wage floor.

Run `cd apps/backend && uv sync && uv run uvicorn app.main:app --reload`, open
<http://localhost:8000/docs>, and start.

---

## Aditya — Lead

Owns the seams. You are not on the critical path for any single feature, which
is deliberate: you are the person who unblocks everyone else.

**Phase 0**
- Freeze the OpenAPI contract for the Phase 1 flow, wire the Dart client
  generator, and turn on the CI drift check (ADR-0005).
- Get the reference device (₹7,000, 2 GB RAM Android) onto a desk.
- Start Bhashini registration — it is a government onboarding queue and it
  will not go faster because we need it later.
- Confirm the roster: six from one institution, at least one female member,
  mentors named. This blocks the internal-round entry, so do it first.
- Ask the SPOC how NBCFDC can be approached about Bharat TULIP ingestion.

**Phase 1**
- Integration, PR review, and holding the scope freeze.
- Write the demo script. Rehearse it with the network switched off.

---

## Flutter A — Capture, on-device ML, enquiries

`lib/features/capture/`, `lib/features/enquiries/`, `lib/ml/`

**Phase 0**
- Camera preview running on the reference device with the app's 64dp targets.
- Get *any* U-2-Net-lite TFLite checkpoint running in an isolate. Do not wait
  for ML's tuned model — prove the plumbing and the latency budget now, swap
  the weights later. Report the measured milliseconds; if the budget is
  unreachable this is the week to find out.

**Phase 1**
- Pre-shutter quality gate: reject blur and backlight, say why aloud.
- Segment → auto-crop → white balance, under 1.5 s.
- Hand the processed image to the cataloger flow.

**You unblock:** the whole demo's first thirty seconds.
**You are blocked by:** nothing. Start today.

---

## Flutter B — Voice cataloger, catalog, pricing UI, i18n

`lib/features/cataloger/`, `lib/features/catalog/`, `lib/features/pricing/`

**Phase 0**
- Audio capture and playback working; TTS speaking Hindi on the device.
- ARB files set up with `hi-IN` and `en-IN`; the analyzer fails the build on a
  missing string, which is intentional.
- Wire the generated client to `/v1/catalog/from-voice`.

**Phase 1**
- Record → send → show extracted attributes → ask the missing ones aloud, one
  question at a time. The API already tells you which fields are missing and
  in what order — use `attributes.missing`.
- Read the generated description back and let her approve or re-record.
- Price screen: floor, suggested, stretch, with the rationale spoken.

**You unblock:** the demo's second sixty seconds.
**You are blocked by:** nothing — the mock endpoints already return your shapes.

---

## Backend

`apps/backend/`

**Phase 0**
- Postgres schema and first Alembic migration for the eleven tables.
- Media upload to MinIO, with the original kept immutable.
- Seed loader for `infra/seeds/crafts.json` and `wages.json`.

**Phase 1**
- Persist products, media, attributes, descriptions and price quotes.
- Wire ARQ so image post-processing is queued, never blocking.
- Serve the buyer portal listing page — it only has to render one listing well.

**Phase 3 is yours too:** the TULIP, ONDC and GeM exporters. Read the plan's
market-linkage section before you design the product schema, so the export
shapes do not surprise you in November.

---

## ML

`packages/ml/`, `apps/backend/app/providers/`

**Phase 0**
- Replace `MockTranscriber` with a Bhashini implementation behind the existing
  interface. Nothing else in the codebase should change — if it does, the
  interface is wrong and we fix the interface.
- Baseline the segmentation checkpoint Flutter A is using, and start tuning.

**Phase 1**
- `DescriptionWriter`: real extraction into `ProductAttributes` and real
  craft-conditioned generation using each craft's `vocabulary`. Generic
  adjectives are the failure mode — "blue cloth" is a bug.
- `PriceEstimator`: comparables band for one craft, hardcoded is fine in
  Phase 1 but **versioned and citable** from Phase 2.

**Rule:** anything a model produced carries a `ProviderStamp`. A price or
description we cannot reproduce is one we will not show an artisan.

**Phase 2 is yours:** the craft classifier over the taxonomy, exported to
INT8 TFLite within the 25 MB budget.

---

## Design + Data

`docs/design/`, `infra/seeds/`, `apps/buyer_portal/`

**Phase 0 — this is the most underrated job on the team**
- The zero-literacy design system: icon set, colour semantics, touch targets,
  spoken-prompt patterns. Both app developers build against it, so it blocks
  them if it is late.
- Verify `infra/seeds/crafts.json`. Every GI claim goes to the GI Registry;
  `kantha_stitch` is marked unverified on purpose. Wrong craft vocabulary
  makes a generated description *confidently* wrong, which a buyer spots
  before we do.
- Fill `infra/seeds/wages.json` with real notifications and real `source_ref`
  values. A wage figure we cannot cite is one we cannot defend on stage, and
  the fair-wage floor is our strongest impact claim.

**Phase 1**
- Buyer portal listing page.
- Start the demo video storyboard — do not leave it to December.

---

## Handoff contracts

Three interfaces carry almost all cross-person traffic. Change them by PR with
the owner tagged, never quietly:

| Contract | Between | Where |
|---|---|---|
| `ProductAttributes` | ML ↔ both app devs | `app/providers/base.py` |
| `PriceQuote` | ML ↔ Flutter B | `app/providers/base.py` |
| OpenAPI schema | Backend ↔ both app devs | generated → `packages/api_client_dart/` |

## Rhythm

- **Daily:** ten minutes, standing. Blockers only.
- **Sunday:** demo on the reference device. Whatever is not demoable did not
  happen this week.
- **14 September:** scope freezes. Everything after that is additive and
  behind a flag.
