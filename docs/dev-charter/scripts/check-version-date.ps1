#!/usr/bin/env pwsh
# PowerShell counterpart of check-version-date.sh (same behavior).
# Check (and auto-update) VERSION to match the current hour (local) or the
# last non-merge commit's hour (CI). See check-version-date.sh for why
# VERSION uses hour granularity (YYYY-MM-DDThhZ) instead of a plain date.
#
# Usage:
#   pre-commit run check-version-date                     # local: auto-writes VERSION to match the current hour
#   $env:CI=1; pre-commit run --all-files                 # CI: only checks against git log -1 --no-merges (never writes)
#   $env:UPDATE=1; pwsh scripts/check-version-date.ps1     # force-write explicitly
$ErrorActionPreference = 'Stop'

if ($env:CI) {
    $env:TZ = 'UTC'
    $expected = (git log -1 --no-merges --format='%ad' --date=format-local:'%Y-%m-%dTHHZ')
} else {
    $expected = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH') + 'Z'
}

$actual = ''
if (Test-Path 'VERSION') {
    $actual = Get-Content -Path 'VERSION' -TotalCount 1
}

if ($env:UPDATE -eq '1') {
    Set-Content -Path 'VERSION' -Value $expected
    Write-Host "VERSION updated to $expected"
    exit 0
}

if ($actual -eq $expected) {
    exit 0
}

if ($env:CI) {
    Write-Host "VERSION ($actual) must be $expected"
    Write-Host 'To fix: $env:UPDATE=1; pwsh scripts/check-version-date.ps1'
    exit 1
}

# Local: auto-write and exit 1 so pre-commit reports the file as changed.
Set-Content -Path 'VERSION' -Value $expected
Write-Host "VERSION ($actual) updated to $expected"
exit 1
