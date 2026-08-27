from __future__ import annotations

from fastapi import FastAPI

from app.api.v1.router import router as v1_router
from app.config import get_settings

settings = get_settings()

app = FastAPI(
    title="Karigar API",
    version="0.1.0",
    description=(
        "Market on-ramp for marginalised artisans. SIH 2026, PS 26090 "
        "(Ministry of Social Justice and Empowerment)."
    ),
)
app.include_router(v1_router)


@app.get("/", include_in_schema=False)
async def root() -> dict[str, str]:
    return {
        "service": "karigar-api",
        "provider_profile": settings.provider_profile.value,
        "docs": "/docs",
    }
