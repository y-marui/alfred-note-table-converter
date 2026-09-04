#!/usr/bin/env pwsh
# PowerShell counterpart of check-charter-subtree-edit.sh (same behavior).
# Block commits that directly edit files under the installed dev-charter
# subtree (INSTALL_CHECKLIST.md: "docs/dev-charter/ 配下のファイルを直接
# 編集しないこと"). The only sanctioned way to change that tree is
# `git subtree add`/`pull --squash`.
#
# `git subtree` builds its "Squashed content" commit via `git commit-tree`,
# which never touches this hook — but the commit that actually joins that
# squashed history into the current branch (what `add`/`pull`/`merge` do
# last) is a real merge commit made via the normal commit machinery, which
# DOES run pre-commit hooks. An earlier version of this hook assumed
# subtree bypasses hooks entirely and got the working tree stuck mid-merge
# the first time a real (conflicting) subtree pull needed a manual
# `git commit` to finish.
#
# Skip the check only when MERGE_HEAD points at a commit carrying a
# `git-subtree-dir: $PREFIX` trailer — the marker `git subtree` itself
# writes into the squashed commit it merges in, exact-matching this hook's
# own prefix. A bare "we're mid-merge" check would exempt any merge,
# including an unrelated one that happens to also touch a file under the
# prefix (e.g. resolving a conflict on a branch where someone edited it
# directly).
#
# Override the subtree path with CHARTER_PREFIX if it was installed
# somewhere other than the default.
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$prefix = if ($env:CHARTER_PREFIX) { $env:CHARTER_PREFIX } else { 'docs/dev-charter' }

$mergeHeadPath = git rev-parse --git-path MERGE_HEAD 2>$null
if ($LASTEXITCODE -eq 0 -and $mergeHeadPath -and (Test-Path $mergeHeadPath)) {
    $mergeHeadSha = (Get-Content $mergeHeadPath -Raw).Trim()
    $commitLines = git log -1 --format=%B $mergeHeadSha 2>$null
    if ($LASTEXITCODE -eq 0 -and $commitLines -contains "git-subtree-dir: ${prefix}") {
        exit 0
    }
}

$changed = git diff --cached --name-only -- $prefix
if ([string]::IsNullOrEmpty($changed)) { exit 0 }

Write-Host "error: ${prefix}/ 配下は直接編集禁止です。"
Write-Host '  変更が必要な場合は dev-charter リポジトリに Issue を立て、git subtree pull で取り込んでください。'
exit 1
