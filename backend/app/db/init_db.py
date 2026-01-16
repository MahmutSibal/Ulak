from __future__ import annotations

import re

from sqlalchemy import create_engine, text
from sqlalchemy.engine.url import make_url

from app.core.config import settings
from app.db.base import Base


_DB_NAME_RE = re.compile(r"^[A-Za-z0-9_\-]+$")


def init_db() -> None:
    """Ensure database exists and create tables.

    - Creates DB if missing (SQL Server).
    - Creates tables via SQLAlchemy metadata.

    Notes:
    - Requires the SQL Server login (or Integrated Security) to have CREATE DATABASE permission.
    """

    url = make_url(settings.database_url)
    db_name = url.database

    if db_name:
        _ensure_database_exists(db_name)

    # Import models to register them with Base.metadata
    from app.db import models  # noqa: F401

    engine = create_engine(settings.database_url, pool_pre_ping=True, future=True)
    Base.metadata.create_all(bind=engine)


def _ensure_database_exists(db_name: str) -> None:
    if not _DB_NAME_RE.match(db_name):
        raise RuntimeError("Database adı geçersiz karakter içeriyor.")

    base_url = make_url(settings.database_url)
    master_url = base_url.set(database="master")

    engine = create_engine(str(master_url), pool_pre_ping=True, future=True, isolation_level="AUTOCOMMIT")
    try:
        with engine.connect() as conn:
            # DB_ID parametrelenebilir; CREATE DATABASE object adı parametrelenemez.
            exists = conn.execute(text("SELECT DB_ID(:db)"), {"db": db_name}).scalar()
            if exists is None:
                conn.execute(text(f"CREATE DATABASE [{db_name}]"))
    finally:
        engine.dispose()
