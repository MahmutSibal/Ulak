from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    first_name: str = Field(min_length=1, max_length=100)
    last_name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    password: str
    password_confirm: str
    security_question: str = Field(min_length=1, max_length=255)
    security_answer: str = Field(min_length=1, max_length=255)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_at: datetime
    must_change_password: bool


class ForgotPasswordQuestionRequest(BaseModel):
    email: EmailStr


class ForgotPasswordQuestionResponse(BaseModel):
    security_question: str


class ForgotPasswordResetRequest(BaseModel):
    email: EmailStr
    security_answer: str


class ForgotPasswordResetResponse(BaseModel):
    new_password: str


class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str
    new_password_confirm: str
