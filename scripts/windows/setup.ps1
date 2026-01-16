$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$backendDir = Join-Path $repoRoot 'backend'
$frontendDir = Join-Path $repoRoot 'frontend'
$venvDir = Join-Path $repoRoot '.venv'

Write-Host "Repo: $repoRoot"

# --- Python venv + backend deps ---
if (-not (Test-Path $venvDir)) {
  Write-Host "Creating venv at $venvDir"
  python -m venv $venvDir
}

$pythonExe = Join-Path $venvDir 'Scripts\python.exe'
if (-not (Test-Path $pythonExe)) {
  throw "Python venv not found at $pythonExe"
}

Write-Host "Installing backend dependencies..."
& $pythonExe -m pip install --upgrade pip
& $pythonExe -m pip install -r (Join-Path $backendDir 'requirements.txt')

# Create backend .env if missing
$backendEnv = Join-Path $backendDir '.env'
$backendEnvExample = Join-Path $backendDir '.env.example'
if (-not (Test-Path $backendEnv) -and (Test-Path $backendEnvExample)) {
  Copy-Item $backendEnvExample $backendEnv
  Write-Host "Created backend/.env from .env.example (edit DATABASE_URL, JWT_SECRET)"
}

# --- Node deps ---
Write-Host "Installing frontend dependencies..."
Push-Location $frontendDir
try {
  if (Test-Path (Join-Path $frontendDir 'package-lock.json')) {
    npm ci
  } else {
    npm install
  }
} finally {
  Pop-Location
}

Write-Host "Setup OK."