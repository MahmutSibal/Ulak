$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$backendDir = Join-Path $repoRoot 'backend'
$frontendDir = Join-Path $repoRoot 'frontend'
$venvDir = Join-Path $repoRoot '.venv'
$pythonExe = Join-Path $venvDir 'Scripts\python.exe'

if (-not (Test-Path $pythonExe)) {
  throw "Venv not found. Run scripts\\windows\\setup.ps1 first. Expected: $pythonExe"
}

Write-Host "Building frontend (Vite)..."
Push-Location $frontendDir
try {
  npm run build
} finally {
  Pop-Location
}

Write-Host "Starting backend (serves UI + API) at http://localhost:8000 ..."
Push-Location $backendDir
try {
  & $pythonExe -m uvicorn app.main:app --host 0.0.0.0 --port 8000
} finally {
  Pop-Location
}