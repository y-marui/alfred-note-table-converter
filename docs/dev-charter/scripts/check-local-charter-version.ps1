#!/usr/bin/env pwsh
# PowerShell counterpart of check-local-charter-version.sh (same behavior).
# Compare this repo's installed dev-charter VERSION against a sibling
# ../dev-charter checkout's same-variant branch (full, lite, etc.).
#
# Expected layout:
#   <parent>/dev-charter/     a local clone of dev-charter
#   <parent>/<this-repo>/     this repository
#
# - sibling branch newer than installed  -> block (a confirmed, actionable gap: run git subtree pull)
# - sibling branch older than installed  -> warn only (sibling itself may just be un-pulled)
# - equal, or either VERSION unavailable -> silent
#
# Reads VERSION from the sibling's local ref (not its working tree), so the
# result doesn't depend on whatever branch happens to be checked out there.
# The default ref is auto-detected from the installed CHARTER_INDEX.md's
# `# Charter Index (<branch>)` marker (falls back to 'full' if absent).
# Override with CHARTER_PREFIX / CHARTER_LOCAL_PATH / CHARTER_LOCAL_REF env vars if needed.
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = (git rev-parse --show-toplevel).Trim()
$prefix = if ($env:CHARTER_PREFIX) { $env:CHARTER_PREFIX } else { 'docs/dev-charter' }
$localCharter = if ($env:CHARTER_LOCAL_PATH) { $env:CHARTER_LOCAL_PATH } else { Join-Path (Split-Path $repoRoot -Parent) 'dev-charter' }

$defaultRef = 'full'
$installedIndex = Join-Path $repoRoot "$prefix/CHARTER_INDEX.md"
if (Test-Path $installedIndex) {
    $firstLine = Get-Content -Path $installedIndex -TotalCount 1
    if ($firstLine -match '\(([a-z0-9_-]+)\)$') { $defaultRef = $Matches[1] }
}
$localRef = if ($env:CHARTER_LOCAL_REF) { $env:CHARTER_LOCAL_REF } else { $defaultRef }

$installedVersionFile = Join-Path $repoRoot "$prefix/VERSION"

if (-not (Test-Path $installedVersionFile)) { exit 0 }
if (-not (Test-Path $localCharter)) { exit 0 }

$installed = Get-Content -Path $installedVersionFile -TotalCount 1

# A plain `git clone` normally has no local full/lite branch, only a
# `<remote>/<ref>` remote-tracking branch, so fall back to that.
$local = $null
foreach ($candidate in @($localRef, "origin/$localRef")) {
    $value = (git -C $localCharter show "${candidate}:VERSION" 2>$null | Select-Object -First 1)
    if (-not [string]::IsNullOrEmpty($value)) { $local = $value; break }
}
if ([string]::IsNullOrEmpty($local)) { exit 0 }

if ($local -eq $installed) {
    exit 0
}

if ([string]::CompareOrdinal($local, $installed) -gt 0) {
    Write-Host "error: ${localCharter} の ${localRef} ブランチの VERSION (${local}) が ${prefix}/VERSION (${installed}) より新しいです。"
    Write-Host '  git subtree pull で dev-charter を更新してからコミットしてください。'
    exit 1
}

Write-Host "warning: ${localCharter} の ${localRef} ブランチの VERSION (${local}) は ${prefix}/VERSION (${installed}) より古いです。"
Write-Host "  (${localCharter} の ${localRef} 自体が fetch/pull 済みでない可能性があるため、警告にとどめています)"
exit 0
