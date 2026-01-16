from __future__ import annotations

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.core.config import settings
from app.core.security import create_access_token, hash_secret, verify_secret
from app.core.validators import generate_temp_password, validate_password_6_digits
from app.db.models import AuthSession, User
from app.schemas.auth import (
    ChangePasswordRequest,
    ForgotPasswordQuestionRequest,
    ForgotPasswordQuestionResponse,
    ForgotPasswordResetRequest,
    ForgotPasswordResetResponse,
    LoginRequest,
    RegisterRequest,
    TokenResponse,
)


router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", status_code=201)
def register(payload: RegisterRequest, db: Session = Depends(get_db)) -> dict:
    if payload.password != payload.password_confirm:
        raise HTTPException(status_code=400, detail="Şifreler eşleşmiyor.")

    try:
        validate_password_6_digits(payload.password)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    existing = db.scalar(select(User).where(User.email == payload.email))
    if existing:
        raise HTTPException(status_code=409, detail="Bu e-posta zaten kayıtlı.")

    user = User(
        first_name=payload.first_name.strip(),
        last_name=payload.last_name.strip(),
        email=str(payload.email).lower(),
        password_hash=hash_secret(payload.password),
        security_question=payload.security_question.strip(),
        security_answer_hash=hash_secret(payload.security_answer.strip().lower()),
        must_change_password=False,
        failed_login_attempts=0,
        locked_until=None,
        created_at=datetime.now(timezone.utc),
        last_login_at=None,
    )
    db.add(user)
    db.commit()
    return {"id": str(user.id)}


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, request: Request, db: Session = Depends(get_db)) -> TokenResponse:
    user = db.scalar(select(User).where(User.email == str(payload.email).lower()))
    if not user:
        raise HTTPException(status_code=401, detail="E-posta veya şifre hatalı.")

    now = datetime.now(timezone.utc)

    if user.locked_until and user.locked_until > now:
        raise HTTPException(status_code=423, detail="Hesap geçici olarak kilitlendi. Daha sonra tekrar deneyin.")

    if not verify_secret(payload.password, user.password_hash):
        user.failed_login_attempts = (user.failed_login_attempts or 0) + 1
        if user.failed_login_attempts >= settings.max_failed_login_attempts:
            user.locked_until = now + timedelta(minutes=settings.lockout_minutes)
            user.failed_login_attempts = 0
        db.add(user)
        db.commit()
        raise HTTPException(status_code=401, detail="E-posta veya şifre hatalı.")

    # success
    user.failed_login_attempts = 0
    user.locked_until = None
    user.last_login_at = now

    token, expires_at = create_access_token(str(user.id))
    session = AuthSession(
        user_id=user.id,
        created_at=now,
        expires_at=expires_at,
        revoked=False,
    )
    db.add_all([user, session])
    db.commit()

    return TokenResponse(
        access_token=token,
        expires_at=expires_at,
        must_change_password=bool(user.must_change_password),
    )


@router.post("/forgot-password/question", response_model=ForgotPasswordQuestionResponse)
def forgot_password_question(payload: ForgotPasswordQuestionRequest, db: Session = Depends(get_db)) -> ForgotPasswordQuestionResponse:
    user = db.scalar(select(User).where(User.email == str(payload.email).lower()))
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı.")
    return ForgotPasswordQuestionResponse(security_question=user.security_question)


@router.post("/forgot-password/reset", response_model=ForgotPasswordResetResponse)
def forgot_password_reset(payload: ForgotPasswordResetRequest, db: Session = Depends(get_db)) -> ForgotPasswordResetResponse:
    user = db.scalar(select(User).where(User.email == str(payload.email).lower()))
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı.")

    if not verify_secret(payload.security_answer.strip().lower(), user.security_answer_hash):
        raise HTTPException(status_code=400, detail="Güvenlik cevabı hatalı.")

    new_password = generate_temp_password()
    user.password_hash = hash_secret(new_password)
    user.must_change_password = True
    user.failed_login_attempts = 0
    user.locked_until = None
    db.add(user)
    db.commit()

    return ForgotPasswordResetResponse(new_password=new_password)


@router.post("/change-password")
def change_password(
    payload: ChangePasswordRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict:
    if payload.new_password != payload.new_password_confirm:
        raise HTTPException(status_code=400, detail="Yeni şifreler eşleşmiyor.")

    try:
        validate_password_6_digits(payload.new_password)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    if not verify_secret(payload.old_password, current_user.password_hash):
        raise HTTPException(status_code=400, detail="Mevcut şifre hatalı.")

    current_user.password_hash = hash_secret(payload.new_password)
    current_user.must_change_password = False
    db.add(current_user)
    db.commit()

    return {"status": "ok"}
