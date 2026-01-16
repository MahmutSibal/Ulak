from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, EmailStr


class UserPublic(BaseModel):
    id: uuid.UUID
    first_name: str
    last_name: str
    email: EmailStr
    must_change_password: bool
    created_at: datetime
    last_login_at: datetime | None

    model_config = {"from_attributes": True}
