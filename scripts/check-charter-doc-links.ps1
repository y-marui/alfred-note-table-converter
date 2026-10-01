#!/usr/bin/env pwsh
# PowerShell counterpart of check-charter-doc-links.sh (same behavior).
# Adopting repos sometimes update a docs/dev-charter/... reference to anticipate
# an upstream restructuring (e.g. a topics/<stack>/ move) before actually running
# `make update-charter` to pull it in, leaving a broken link until a follow-up
# subtree-sync PR lands (see dev-charter#131's python-package-template/
# python-closed-template follow-up). This hook catches that at commit time by
# verifying every docs/dev-charter/... path mentioned in the adopting repo's own
# tracked Markdown files actually exists on disk.
#
# AI_CONTEXT.md が無いプロジェクト（未導入 or 導入前）は対象外。
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = (git rev-parse --show-toplevel).Trim()
Set-Location $repoRoot

# dev-charter 自身のリポジトリには docs/dev-charter/ が存在しない（配布物であり
# 自分自身の subtree ではないため）。この場合は未導入と同様に対象外とする。
if (-not (Test-Path 'docs/dev-charter' -PathType Container)) { exit 0 }

$status = 0
$files = git ls-files '*.md' | Where-Object { $_ -notmatch '^docs/dev-charter/' }
foreach ($file in $files) {
    $content = Get-Content $file -Raw
    $refs = [regex]::Matches($content, 'docs/dev-charter/[A-Za-z0-9_./-]+\.md') |
        ForEach-Object { $_.Value } | Select-Object -Unique
    foreach ($ref in $refs) {
        if (-not (Test-Path $ref)) {
            Write-Host "error: ${file} が存在しないパスを参照しています: ${ref}"
            $status = 1
        }
    }
}

exit $status
