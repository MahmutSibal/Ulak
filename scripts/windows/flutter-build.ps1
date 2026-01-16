param(
  [string]$ApiBaseUrl = "http://localhost:8000"
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $repoRoot

Write-Host "Flutter Windows build (Release)"
Write-Host "API_BASE_URL = $ApiBaseUrl"

flutter doctor
flutter pub get

flutter build windows --release --dart-define=API_BASE_URL=$ApiBaseUrl

$exePath = Join-Path $repoRoot 'build\windows\x64\runner\Release\ulak.exe'
if (Test-Path $exePath) {
  Write-Host "EXE hazır: $exePath"
} else {
  Write-Host "Build bitti ama exe yolu bulunamadı. Çıktıyı kontrol et: build\\windows\\x64\\runner\\Release\\"
}
