#!/usr/bin/env pwsh
# PowerShell counterpart of check-license-exists.sh (same behavior).
# LEGAL_POLICY.md: "すべてのリポジトリに LICENSE ファイルを含める。
# ライセンスなしでの公開は禁止。" を機械的に検証する。
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = (git rev-parse --show-toplevel).Trim()

$licenseFiles = Get-ChildItem -Path $repoRoot -Filter 'LICENSE*' -File -ErrorAction SilentlyContinue
if (-not $licenseFiles) {
    Write-Host 'error: LICENSE ファイルがありません。'
    Write-Host '  (LEGAL_POLICY.md: すべてのリポジトリに LICENSE ファイルを含める)'
    exit 1
}

exit 0
