#!/usr/bin/env pwsh
# PowerShell counterpart of check-local-charter-version.sh (same behavior).
# Compare this repo's installed dev-charter VERSION against a sibling
# ../dev-charter checkout.
#
# Expected layout:
#   <parent>/dev-charter/     a local clone of dev-charter
#   <parent>/<this-repo>/     this repository
#
# - sibling newer than installed  -> block (a confirmed, actionable gap: run git subtree pull)
# - sibling older than installed  -> warn only (sibling itself may just be un-pulled)
# - equal, or either VERSION file missing -> silent
#
# Override with CHARTER_PREFIX / CHARTER_LOCAL_PATH env vars if needed.
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = (git rev-parse --show-toplevel).Trim()
$prefix = if ($env:CHARTER_PREFIX) { $env:CHARTER_PREFIX } else { 'docs/dev-charter' }
$localCharter = if ($env:CHARTER_LOCAL_PATH) { $env:CHARTER_LOCAL_PATH } else { Join-Path (Split-Path $repoRoot -Parent) 'dev-charter' }

$installedVersionFile = Join-Path $repoRoot "$prefix/VERSION"
$localVersionFile = Join-Path $localCharter 'VERSION'

if (-not (Test-Path $installedVersionFile)) { exit 0 }
if (-not (Test-Path $localVersionFile)) { exit 0 }

$installed = Get-Content -Path $installedVersionFile -TotalCount 1
$local = Get-Content -Path $localVersionFile -TotalCount 1

if ($local -eq $installed) {
    exit 0
}

if ([string]::CompareOrdinal($local, $installed) -gt 0) {
    Write-Host "error: ${localCharter} の VERSION (${local}) が ${prefix}/VERSION (${installed}) より新しいです。"
    Write-Host '  git subtree pull で dev-charter を更新してからコミットしてください。'
    exit 1
}

Write-Host "warning: ${localCharter} の VERSION (${local}) は ${prefix}/VERSION (${installed}) より古いです。"
Write-Host "  (${localCharter} 自体が fetch/pull 済みでない可能性があるため、警告にとどめています)"
exit 0
