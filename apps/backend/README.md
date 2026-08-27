# Karigar backend

FastAPI + Postgres/pgvector + Redis/ARQ. See `docs/adr/` for why.

## Run

```bash
uv sync                       # installs Python 3.11 if you don't have it
cp .env.example .env
docker compose -f ../../infra/docker-compose.yml up -d
uv run alembic upgrade head
uv run uvicorn app.main:app --reload
```

Open http://localhost:8000/docs

## Check before you push

```bash
uv run ruff format . && uv run ruff check --fix .
uv run mypy app
uv run pytest
```

## Layout

| Path | Rule |
|---|---|
| `app/api/` | Routers only. Parse, call a use case, serialise. No business logic. |
| `app/domain/` | Entities and use cases. **Imports nothing from FastAPI or SQLAlchemy.** |
| `app/providers/` | AI adapters (ADR-0002). Business logic imports the ABC, never a concrete class. |
| `app/exporters/` | Bharat TULIP, ONDC, GeM catalog emitters. |
| `app/workers/` | ARQ tasks. Thin wrappers over use cases. |
| `app/db/` | SQLAlchemy models, Alembic migrations, seed loaders. |

Run everything with `PROVIDER_PROFILE=mock` and no network before you claim a
feature works.
