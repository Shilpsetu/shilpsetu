"""Application settings. Everything configurable lives here, nothing elsewhere."""

from __future__ import annotations

from enum import StrEnum
from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class ProviderProfile(StrEnum):
    """Preset provider bundles. See ADR-0002."""

    MOCK = "mock"
    BHASHINI = "bhashini"
    LOCAL = "local"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_env: str = "local"
    log_level: str = "INFO"

    database_url: str = "postgresql+asyncpg://karigar:karigar@localhost:5432/karigar"
    redis_url: str = "redis://localhost:6379/0"

    s3_endpoint_url: str = "http://localhost:9000"
    s3_bucket: str = "karigar-media"
    s3_access_key: str = "karigar"
    s3_secret_key: str = "karigar-dev-secret"

    # Provider selection ------------------------------------------------------
    provider_profile: ProviderProfile = ProviderProfile.MOCK
    provider_transcriber: str | None = None
    provider_translator: str | None = None
    provider_writer: str | None = None
    provider_enhancer: str | None = None
    provider_pricer: str | None = None

    bhashini_user_id: str | None = None
    bhashini_api_key: str | None = None
    bhashini_pipeline_id: str | None = None

    def resolve(self, capability: str) -> str:
        """Per-capability override wins over the profile."""
        override: str | None = getattr(self, f"provider_{capability}", None)
        return override or self.provider_profile.value


@lru_cache
def get_settings() -> Settings:
    return Settings()
