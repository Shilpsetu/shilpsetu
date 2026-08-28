# Shilpsetu

**Smart India Hackathon 2026 · Problem Statement 26090**
Ministry of Social Justice and Empowerment · Software · Heritage & Culture

A voice-first mobile application that turns a photograph and a spoken sentence
into a sellable listing, then pushes it onto the marketplaces the Ministry
already runs.

> We are not proposing a new platform. Bharat TULIP exists — an Amazon.in
> storefront, Mystore listings, four curated collections — and it has served
> roughly 1,500 artisans against 54 lakh beneficiaries. The channel is not the
> problem. **Getting onto it is.** Shilpsetu is the on-ramp.

## ▶ New here? Open [`START_HERE.md`](START_HERE.md)

It routes you to your role, your exact folders, and your first three tasks.
Two minutes and you are working.

## The four bets

1. **Zero-literacy by construction** — no typing on the artisan's critical
   path. Acceptance test: a person who cannot read completes a full listing
   unaided.
2. **Craft-aware, not craft-blind** — an on-device classifier identifies the
   craft first, and that class conditions segmentation, vocabulary, keywords
   and pricing comparables.
3. **A wage floor, not a black box** — materials plus hours at the state
   fair-wage rate, a craft-matched market band, and the gap shown between
   them. The app will not publish below the floor.
4. **Feed the channel that already exists** — Bharat TULIP first, then ONDC,
   GeM and a B2B buyer portal. Enquiries return as a spoken alert in her
   language.

## Getting started

```bash
# Backend — works immediately, no credentials needed
cd apps/backend
uv sync && cp .env.example .env
uv run pytest                                   # 17 tests, all green
uv run uvicorn app.main:app --reload            # http://localhost:8000/docs

# With real infrastructure
docker compose -f infra/docker-compose.yml up -d

# Mobile
cd apps/mobile
flutter create . --platforms=android,ios --org in.shilpsetu.app --project-name shilpsetu
flutter pub get && flutter run
```

`PROVIDER_PROFILE=mock` is the default and runs the entire listing flow with
**no network and no API keys**. That is deliberate: it is how new teammates
start in five minutes, and it is our insurance when the venue wifi dies.

## Layout

```
apps/backend      FastAPI + Postgres/pgvector + Redis/ARQ
apps/mobile       Flutter, feature-first — folders are ownership boundaries
apps/buyer_portal Server-rendered demand-side surface
packages/ml       Model training and TFLite export
packages/api_client_dart   GENERATED from OpenAPI — never hand-edited
infra             docker-compose, seed data (craft taxonomy, wage basis)
docs/adr          The six decisions, with the costs we accepted
docs/WORKLOAD.md  Who builds what, and in what order
tools             gen_api.sh, seed_issues.sh, check_setup.sh
```

## For the lead, once

```bash
# 1. put real GitHub handles in .github/CODEOWNERS and START_HERE.md
./tools/check_setup.sh            # tells you if you missed something
./tools/seed_issues.sh --dry-run  # preview 29 issues across the six of you
./tools/seed_issues.sh            # create them, labelled and assigned
```

## Read before you write code

| Document | Why |
|---|---|
| [`START_HERE.md`](START_HERE.md) | **Start here.** Your role, folders and first tasks. |
| [`docs/shilpsetu-plan-v1.html`](docs/shilpsetu-plan-v1.html) | The full plan. Open it in a browser. |
| [`docs/WORKLOAD.md`](docs/WORKLOAD.md) | Your tasks and your file boundaries. |
| [`docs/adr/`](docs/adr/) | Why the architecture is the way it is. |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Definition of done. Read the non-negotiables. |
