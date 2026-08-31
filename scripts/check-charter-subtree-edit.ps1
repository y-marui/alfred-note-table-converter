#!/usr/bin/env pwsh
# PowerShell counterpart of check-charter-subtree-edit.sh (same behavior).
# Block commits that directly edit files under the installed dev-charter
# subtree (INSTALL_CHECKLIST.md: "docs/dev-charter/ 配下のファイルを直接
# 編集しないこと"). The only sanctioned way to change that tree is
# `git subtree add`/`pull --squash`, and those bypass the normal commit
# hooks entirely (git-subtree builds the squash commit with
# `git commit-tree` rather than `git commit`), so this hook never sees
# a legitimate subtree update — anything it does see staged under the
# prefix is a direct edit and gets rejected.
#
# Override the subtree path with CHARTER_PREFIX if it was installed
# somewhere other than the default.
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$prefix = if ($env:CHARTER_PREFIX) { $env:CHARTER_PREFIX } else { 'docs/dev-charter' }

$changed = git diff --cached --name-only -- $prefix
if ([string]::IsNullOrEmpty($changed)) { exit 0 }

Write-Host "error: ${prefix}/ 配下は直接編集禁止です。"
Write-Host '  変更が必要な場合は dev-charter リポジトリに Issue を立て、git subtree pull で取り込んでください。'
exit 1
