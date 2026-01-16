from __future__ import annotations

from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field


_ENV_PATH = Path(__file__).resolve().parents[2] / ".env"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=str(_ENV_PATH), env_file_encoding="utf-8", extra="ignore")

    app_name: str = Field(default="ulak-backend", alias="APP_NAME")
    env: str = Field(default="dev", alias="ENV")
    api_prefix: str = Field(default="/api", alias="API_PREFIX")

    jwt_secret: str = Field(alias="JWT_SECRET")
    jwt_algorithm: str = Field(default="HS256", alias="JWT_ALGORITHM")
    access_token_expire_minutes: int = Field(default=60, alias="ACCESS_TOKEN_EXPIRE_MINUTES")

    max_failed_login_attempts: int = Field(default=5, alias="MAX_FAILED_LOGIN_ATTEMPTS")
    lockout_minutes: int = Field(default=15, alias="LOCKOUT_MINUTES")

    ip_allowlist: str | None = Field(default=None, alias="IP_ALLOWLIST")
    ip_blocklist: str | None = Field(default=None, alias="IP_BLOCKLIST")

    database_url: str = Field(alias="DATABASE_URL")

    cors_origins: str | None = Field(default=None, alias="CORS_ORIGINS")

    def parsed_cors_origins(self) -> list[str]:
        if not self.cors_origins:
            return []
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    def parsed_ip_allowlist(self) -> set[str]:
        if not self.ip_allowlist:
            return set()
        return {i.strip() for i in self.ip_allowlist.split(",") if i.strip()}

    def parsed_ip_blocklist(self) -> set[str]:
        if not self.ip_blocklist:
            return set()
        return {i.strip() for i in self.ip_blocklist.split(",") if i.strip()}


settings = Settings()  # type: ignore[call-arg]
