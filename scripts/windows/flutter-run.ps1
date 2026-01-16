param(
  [string]$ApiBaseUrl = "http://localhost:8000",
  [switch]$Clean
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $repoRoot

Write-Host "Flutter Windows run"
Write-Host "API_BASE_URL = $ApiBaseUrl"

flutter doctor
flutter pub get

if ($Clean) {
  flutter clean
  flutter pub get
}

# Run Windows desktop app
flutter run -d windows --dart-define=API_BASE_URL=$ApiBaseUrl
