$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$backendDir = Join-Path $repoRoot 'backend'
$frontendDir = Join-Path $repoRoot 'frontend'
$venvDir = Join-Path $repoRoot '.venv'
$pythonExe = Join-Path $venvDir 'Scripts\python.exe'

if (-not (Test-Path $pythonExe)) {
  throw "Venv not found. Run scripts\\windows\\setup.ps1 first. Expected: $pythonExe"
}

Write-Host "Starting backend (http://localhost:8000)..."
Start-Process -FilePath powershell -ArgumentList @(
  '-NoExit',
  '-Command',
  "cd '$backendDir'; & '$pythonExe' -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
)

Write-Host "Starting frontend dev server (http://localhost:5173)..."
Start-Process -FilePath powershell -ArgumentList @(
  '-NoExit',
  '-Command',
  "cd '$frontendDir'; npm run dev"
)

Write-Host "Dev started."