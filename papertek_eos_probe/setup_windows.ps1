$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

Write-Host 'Checking Flutter installation...'
flutter --version
if ($LASTEXITCODE -ne 0) { throw 'Flutter was not found on PATH.' }

Write-Host 'Enabling Windows desktop support...'
flutter config --enable-windows-desktop

$backupRoot = Join-Path $env:TEMP ("papertek_eos_probe_source_" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $backupRoot | Out-Null

$sourceItems = @(
  'lib',
  'test',
  'packages',
  'pubspec.yaml',
  'analysis_options.yaml',
  'README.md'
)

try {
  foreach ($item in $sourceItems) {
    $source = Join-Path $projectRoot $item
    if (Test-Path $source) {
      Copy-Item $source -Destination $backupRoot -Recurse -Force
    }
  }

  try {
    Write-Host 'Generating the local Windows runner...'
    flutter create --platforms=windows --project-name papertek_eos_probe --no-pub .
    if ($LASTEXITCODE -ne 0) { throw 'flutter create failed.' }
  }
  finally {
    Write-Host 'Restoring the supplied project source...'
    foreach ($item in $sourceItems) {
      $destination = Join-Path $projectRoot $item
      $backup = Join-Path $backupRoot $item
      if (Test-Path $backup) {
        if (Test-Path $destination) {
          Remove-Item $destination -Recurse -Force
        }
        Copy-Item $backup -Destination $projectRoot -Recurse -Force
      }
    }
  }

  Write-Host 'Resolving Flutter application dependencies...'
  flutter pub get
  if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed.' }

  Write-Host 'Resolving reusable Dart package test dependencies...'
  Push-Location (Join-Path $projectRoot 'packages\eos_osc_client')
  try {
    dart pub get
    if ($LASTEXITCODE -ne 0) { throw 'dart pub get failed in eos_osc_client.' }
  }
  finally {
    Pop-Location
  }

  Write-Host ''
  Write-Host 'Windows setup complete.' -ForegroundColor Green
  Write-Host 'Next commands:'
  Write-Host '  flutter analyze'
  Write-Host '  Push-Location .\packages\eos_osc_client; dart test; Pop-Location'
  Write-Host '  flutter test'
  Write-Host '  flutter run -d windows'
}
finally {
  if (Test-Path $backupRoot) {
    Remove-Item $backupRoot -Recurse -Force
  }
}
