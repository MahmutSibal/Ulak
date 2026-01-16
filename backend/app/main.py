from __future__ import annotations

import logging

from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse

from app.core.config import settings
from app.core.ip_filter import IPFilterMiddleware
from app.api.routes.auth import router as auth_router
from app.api.routes.transfers import router as transfers_router
from app.db.init_db import init_db


logging.basicConfig(level=logging.INFO)


_REPO_ROOT = Path(__file__).resolve().parents[3]
_FRONTEND_DIST = _REPO_ROOT / "frontend" / "dist"
_FRONTEND_INDEX = _FRONTEND_DIST / "index.html"
_SERVE_FRONTEND = _FRONTEND_INDEX.exists()


@asynccontextmanager
async def lifespan(_: FastAPI):
    init_db()
    yield


app = FastAPI(title=settings.app_name, lifespan=lifespan)

app.add_middleware(IPFilterMiddleware)

cors = settings.parsed_cors_origins()
if settings.env.lower() == "dev":
    # Flutter web runs on a random localhost port during `flutter run -d chrome`.
    # Always allow localhost:* in dev. Keep any explicit allowlist too.
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors,
        allow_origin_regex=r"^http://localhost(:\\d+)?$|^http://127\\.0\\.0\\.1(:\\d+)?$",
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
elif cors:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"]
    )

app.include_router(auth_router, prefix=settings.api_prefix)
app.include_router(transfers_router, prefix=settings.api_prefix)


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


if _SERVE_FRONTEND:
    @app.get("/", include_in_schema=False)
    def frontend_root() -> FileResponse:
        return FileResponse(_FRONTEND_INDEX)


    @app.get("/{full_path:path}", include_in_schema=False)
    def frontend_spa_fallback(full_path: str, request: Request):
        path = request.url.path

        api_prefix = settings.api_prefix.rstrip("/")
        if api_prefix and (path == api_prefix or path.startswith(api_prefix + "/")):
            raise HTTPException(status_code=404)

        if path in {"/docs", "/redoc", "/openapi.json", "/health"}:
            raise HTTPException(status_code=404)

        candidate = (_FRONTEND_DIST / full_path).resolve()
        try:
            candidate.relative_to(_FRONTEND_DIST)
        except ValueError:
            return FileResponse(_FRONTEND_INDEX)

        if candidate.is_file():
            return FileResponse(candidate)

        return FileResponse(_FRONTEND_INDEX)
