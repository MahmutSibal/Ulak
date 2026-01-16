# ulak-backend (FastAPI)

## Kurulum

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
```

## Çalıştırma

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Swagger: http://localhost:8000/docs

## Notlar

- Bu backend SQL Server için `pyodbc` + SQLAlchemy 2.x kullanır.
- HTTPS/WSS için production’da reverse proxy (Nginx/Traefik/IIS) arkasında çalıştırın.
- Forgot-password akışı MVP olarak yeni şifreyi response içinde döner. Üretimde email/SMS veya tek kullanımlık token ile yapılmalı.
