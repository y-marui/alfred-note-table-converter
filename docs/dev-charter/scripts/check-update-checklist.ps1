#!/usr/bin/env pwsh
# PowerShell counterpart of check-update-checklist.sh (same behavior).
# Fail when a branch changes ONLY files under the installed dev-charter
# subtree (docs/dev-charter) without a sign that UPDATE_CHECKLIST was run.
# Intended for the pre-push stage and CI, not for commit time (a commit-time
# check would block `git subtree pull`).
#
# Passes when: no file under the subtree changed, OR a file outside the
# subtree also changed, OR a commit in base..HEAD has the trailer line
# `Update-Checklist: done`.
#
# Base ref: $env:CHARTER_CHECK_BASE, else origin/HEAD, else origin/main.
# Subtree path: $env:CHARTER_PREFIX (default docs/dev-charter).
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$prefix = if ($env:CHARTER_PREFIX) { $env:CHARTER_PREFIX.TrimEnd('/') } else { 'docs/dev-charter' }

$base = $env:CHARTER_CHECK_BASE
if (-not $base) {
    $base = git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $base) { $base = 'origin/main' }
}

git rev-parse --verify --quiet "$base^{commit}" *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Warning "base ref '$base' not found; skipping UPDATE_CHECKLIST check"
    exit 0
}

$changed = @(git diff --name-only "$base...HEAD" 2>$null)
if ($LASTEXITCODE -ne 0) {
    Write-Warning "no merge base with '$base'; skipping UPDATE_CHECKLIST check"
    exit 0
}
$changed = @($changed | Where-Object { $_ })
if ($changed.Count -eq 0) { exit 0 }

$inside = @($changed | Where-Object { $_.StartsWith("$prefix/") })
$outside = @($changed | Where-Object { -not $_.StartsWith("$prefix/") })
if ($inside.Count -eq 0 -or $outside.Count -gt 0) { exit 0 }

$log = (git log "$base..HEAD" --format=%B) -join "`n"
if ($log -match '(?m)^Update-Checklist: done\s*$') { exit 0 }

Write-Host "error: ${prefix}/ のみを変更する差分に UPDATE_CHECKLIST 実施の印がありません。"
Write-Host "  ${prefix}/UPDATE_CHECKLIST.md を実行し、反映があれば同じブランチに含めてください。"
Write-Host '  反映が不要なら、trailer 付きの空 commit を足してください:'
Write-Host '    git commit --allow-empty -m "chore: confirm UPDATE_CHECKLIST" -m "Update-Checklist: done"'
exit 1
