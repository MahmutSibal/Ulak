from __future__ import annotations

import random
import re


_PASSWORD_RE = re.compile(r"^\d{6}$")


def validate_password_6_digits(password: str) -> None:
    if not _PASSWORD_RE.match(password):
        raise ValueError("Şifre 6 haneli ve sadece rakamlardan oluşmalıdır.")
    if _is_sequential(password):
        raise ValueError("Şifre ardışık rakamlardan oluşamaz (123456, 654321 vb.).")


def _is_sequential(password: str) -> bool:
    digits = [int(c) for c in password]
    asc = all(digits[i] + 1 == digits[i + 1] for i in range(5))
    desc = all(digits[i] - 1 == digits[i + 1] for i in range(5))
    return asc or desc


def generate_temp_password() -> str:
    # 6 haneli, ardışık olmayan geçici şifre üret.
    while True:
        candidate = f"{random.randint(0, 999999):06d}"
        if not _is_sequential(candidate):
            return candidate
