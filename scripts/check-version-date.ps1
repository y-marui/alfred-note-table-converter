#!/usr/bin/env pwsh
# PowerShell counterpart of check-version-date.sh (same behavior).
# Check (or update) VERSION to match today's date (local) or the last non-merge commit date (CI).
#
# Usage:
#   pre-commit run check-version-date                     # local: compares to today
#   $env:CI=1; pre-commit run --all-files                 # CI: compares to git log -1 --no-merges date
#   $env:UPDATE=1; pwsh scripts/check-version-date.ps1     # write expected date to VERSION
$ErrorActionPreference = 'Stop'

if ($env:CI) {
    $env:TZ = 'UTC'
    $expected = (git log -1 --no-merges --format='%ad' --date=format-local:'%Y-%m-%d')
} else {
    $expected = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')
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

if ($actual -ne $expected) {
    Write-Host "VERSION ($actual) must be $expected"
    Write-Host 'To fix: $env:UPDATE=1; pwsh scripts/check-version-date.ps1'
    exit 1
}
