from __future__ import annotations

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

from app.core.config import settings


class IPFilterMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        client_host = request.client.host if request.client else ""
        allowlist = settings.parsed_ip_allowlist()
        blocklist = settings.parsed_ip_blocklist()

        if client_host in blocklist:
            return JSONResponse(status_code=403, content={"detail": "IP engellendi."})

        if allowlist and client_host not in allowlist:
            return JSONResponse(status_code=403, content={"detail": "IP izinli listede değil."})

        return await call_next(request)
