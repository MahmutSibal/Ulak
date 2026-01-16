from __future__ import annotations

from datetime import datetime, timezone
import hashlib
from pathlib import Path
import uuid

from fastapi import APIRouter, Depends, File, HTTPException, Request, UploadFile
from fastapi.responses import FileResponse
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.db.models import TransferLog, TransferSession, TransferStatus, User
from app.schemas.transfer import TransferSessionCreateRequest, TransferSessionPublic


router = APIRouter(prefix="/transfers", tags=["transfers"])


_STORAGE_ROOT = Path(__file__).resolve().parents[3] / "storage"


def _safe_filename(name: str) -> str:
    # Prevent path traversal; keep only the last path segment.
    name = name.replace("\\", "/")
    name = name.split("/")[-1]
    return name or "file"


def _session_dir(transfer_id: uuid.UUID) -> Path:
    return _STORAGE_ROOT / str(transfer_id)


def _session_file_path(session: TransferSession) -> Path:
    return _session_dir(session.id) / _safe_filename(session.file_name)


@router.post("/sessions", response_model=TransferSessionPublic, status_code=201)
def create_transfer_session(
    payload: TransferSessionCreateRequest,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TransferSession:
    if not payload.receiver_user_id and not payload.receiver_ip:
        raise HTTPException(status_code=400, detail="Alıcı olarak receiver_user_id veya receiver_ip zorunludur.")

    now = datetime.now(timezone.utc)
    session = TransferSession(
        sender_user_id=current_user.id,
        receiver_user_id=payload.receiver_user_id,
        receiver_ip=payload.receiver_ip,
        file_name=payload.file_name,
        file_size=payload.file_size,
        file_type=payload.file_type,
        checksum_sha256=payload.checksum_sha256,
        status=TransferStatus.pending,
        created_at=now,
        updated_at=now,
    )

    db.add(session)
    db.flush()

    db.add(
        TransferLog(
            transfer_session_id=session.id,
            event="created",
            message=None,
            ip=request.client.host if request.client else None,
            created_at=now,
        )
    )
    db.commit()
    db.refresh(session)
    return session


@router.get("/sessions", response_model=list[TransferSessionPublic])
def list_transfer_sessions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    limit: int = 50,
    offset: int = 0,
) -> list[TransferSession]:
    limit = max(1, min(limit, 200))
    stmt = (
        select(TransferSession)
        .where(or_(TransferSession.sender_user_id == current_user.id, TransferSession.receiver_user_id == current_user.id))
        .order_by(TransferSession.created_at.desc())
        .offset(offset)
        .limit(limit)
    )
    return list(db.scalars(stmt).all())


@router.post("/sessions/{transfer_id}/upload")
async def upload_file(
    transfer_id: uuid.UUID,
    request: Request,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict:
    session = _get_session_for_action(db, transfer_id)

    if session.sender_user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Bu transfer için upload yetkiniz yok.")

    if session.status in {TransferStatus.rejected, TransferStatus.cancelled, TransferStatus.failed}:
        raise HTTPException(status_code=400, detail="Transfer bu durumda upload edilemez.")

    # Save to disk and compute sha256 while streaming.
    _STORAGE_ROOT.mkdir(parents=True, exist_ok=True)
    target_dir = _session_dir(session.id)
    target_dir.mkdir(parents=True, exist_ok=True)

    target_path = _session_file_path(session)

    hasher = hashlib.sha256()
    size = 0
    tmp_path = target_path.with_suffix(target_path.suffix + ".part")

    try:
        with tmp_path.open("wb") as f:
            while True:
                chunk = await file.read(1024 * 1024)
                if not chunk:
                    break
                size += len(chunk)
                hasher.update(chunk)
                f.write(chunk)
    finally:
        await file.close()

    if size != session.file_size:
        tmp_path.unlink(missing_ok=True)
        session.status = TransferStatus.failed
        session.updated_at = datetime.now(timezone.utc)
        db.add(session)
        db.add(
            TransferLog(
                transfer_session_id=session.id,
                event="upload_failed",
                message=f"Size mismatch: expected={session.file_size} got={size}",
                ip=request.client.host if request.client else None,
                created_at=session.updated_at,
            )
        )
        db.commit()
        raise HTTPException(status_code=400, detail="Dosya boyutu uyuşmuyor.")

    checksum = hasher.hexdigest()
    if checksum.lower() != (session.checksum_sha256 or "").lower():
        tmp_path.unlink(missing_ok=True)
        session.status = TransferStatus.failed
        session.updated_at = datetime.now(timezone.utc)
        db.add(session)
        db.add(
            TransferLog(
                transfer_session_id=session.id,
                event="upload_failed",
                message="Checksum mismatch",
                ip=request.client.host if request.client else None,
                created_at=session.updated_at,
            )
        )
        db.commit()
        raise HTTPException(status_code=400, detail="Checksum uyuşmuyor.")

    # Move into final place.
    tmp_path.replace(target_path)

    session.status = TransferStatus.completed
    session.updated_at = datetime.now(timezone.utc)
    db.add(session)
    db.add(
        TransferLog(
            transfer_session_id=session.id,
            event="uploaded",
            message=None,
            ip=request.client.host if request.client else None,
            created_at=session.updated_at,
        )
    )
    db.commit()

    return {"status": "ok"}


@router.get("/sessions/{transfer_id}/download")
def download_file(
    transfer_id: uuid.UUID,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    session = _get_session_for_action(db, transfer_id)

    if session.receiver_user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Bu transferi indirme yetkiniz yok.")

    if session.status not in {TransferStatus.accepted, TransferStatus.completed}:
        raise HTTPException(status_code=400, detail="Transfer bu durumda indirilemez.")

    path = _session_file_path(session)
    if not path.exists():
        raise HTTPException(status_code=404, detail="Dosya bulunamadı.")

    db.add(
        TransferLog(
            transfer_session_id=session.id,
            event="downloaded",
            message=None,
            ip=request.client.host if request.client else None,
            created_at=datetime.now(timezone.utc),
        )
    )
    db.commit()

    return FileResponse(
        path=str(path),
        filename=_safe_filename(session.file_name),
        media_type="application/octet-stream",
    )


def _get_session_for_action(db: Session, transfer_id: uuid.UUID) -> TransferSession:
    session = db.get(TransferSession, transfer_id)
    if not session:
        raise HTTPException(status_code=404, detail="Transfer oturumu bulunamadı.")
    return session


@router.post("/sessions/{transfer_id}/accept")
def accept_transfer(
    transfer_id: uuid.UUID,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict:
    session = _get_session_for_action(db, transfer_id)

    if session.receiver_user_id and session.receiver_user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Bu transferi kabul etme yetkiniz yok.")

    # If the sender created the session by IP (or left receiver empty), bind it to this user on accept.
    if session.receiver_user_id is None:
        session.receiver_user_id = current_user.id

    if session.status != TransferStatus.pending:
        raise HTTPException(status_code=400, detail="Transfer bu durumda kabul edilemez.")

    now = datetime.now(timezone.utc)
    session.status = TransferStatus.accepted
    session.updated_at = now

    db.add(session)
    db.add(
        TransferLog(
            transfer_session_id=session.id,
            event="accepted",
            message=None,
            ip=request.client.host if request.client else None,
            created_at=now,
        )
    )
    db.commit()

    return {"status": "ok"}


@router.post("/sessions/{transfer_id}/reject")
def reject_transfer(
    transfer_id: uuid.UUID,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict:
    session = _get_session_for_action(db, transfer_id)

    if session.receiver_user_id and session.receiver_user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Bu transferi reddetme yetkiniz yok.")

    if session.status != TransferStatus.pending:
        raise HTTPException(status_code=400, detail="Transfer bu durumda reddedilemez.")

    now = datetime.now(timezone.utc)
    session.status = TransferStatus.rejected
    session.updated_at = now

    db.add(session)
    db.add(
        TransferLog(
            transfer_session_id=session.id,
            event="rejected",
            message=None,
            ip=request.client.host if request.client else None,
            created_at=now,
        )
    )
    db.commit()

    return {"status": "ok"}


@router.post("/sessions/{transfer_id}/cancel")
def cancel_transfer(
    transfer_id: uuid.UUID,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict:
    session = _get_session_for_action(db, transfer_id)

    if session.sender_user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Bu transferi iptal etme yetkiniz yok.")

    if session.status not in {TransferStatus.pending, TransferStatus.accepted, TransferStatus.in_progress}:
        raise HTTPException(status_code=400, detail="Transfer bu durumda iptal edilemez.")

    now = datetime.now(timezone.utc)
    session.status = TransferStatus.cancelled
    session.updated_at = now

    db.add(session)
    db.add(
        TransferLog(
            transfer_session_id=session.id,
            event="cancelled",
            message=None,
            ip=request.client.host if request.client else None,
            created_at=now,
        )
    )
    db.commit()

    return {"status": "ok"}
