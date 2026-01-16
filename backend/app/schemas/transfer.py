from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.db.models import TransferStatus


class TransferSessionCreateRequest(BaseModel):
    receiver_user_id: uuid.UUID | None = None
    receiver_ip: str | None = None

    file_name: str = Field(min_length=1, max_length=512)
    file_size: int = Field(ge=0)
    file_type: str | None = Field(default=None, max_length=128)
    checksum_sha256: str = Field(min_length=64, max_length=64)


class TransferSessionPublic(BaseModel):
    id: uuid.UUID
    sender_user_id: uuid.UUID
    receiver_user_id: uuid.UUID | None
    receiver_ip: str | None

    file_name: str
    file_size: int
    file_type: str | None
    checksum_sha256: str

    status: TransferStatus
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
