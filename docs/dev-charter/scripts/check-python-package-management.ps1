#!/usr/bin/env pwsh
# PowerShell counterpart of check-python-package-management.sh (same behavior).
# topics/PYTHON_DEV_ENV.md: "pyproject.toml で依存関係を管理する
# （requirements.txt は使用しない）" "uv.lock をリポジトリに含め、
# 再現性を担保する" を機械的に検証する。
#
# pyproject.toml が無いプロジェクト（非 Python プロジェクト）は対象外。
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = (git rev-parse --show-toplevel).Trim()

if (-not (Test-Path (Join-Path $repoRoot 'pyproject.toml') -PathType Leaf)) { exit 0 }

$status = 0

if (Test-Path (Join-Path $repoRoot 'requirements.txt') -PathType Leaf) {
    Write-Host 'error: requirements.txt が存在します。'
    Write-Host '  (topics/PYTHON_DEV_ENV.md: pyproject.toml で依存関係を管理する。requirements.txt は使用しない)'
    $status = 1
}

if (-not (Test-Path (Join-Path $repoRoot 'uv.lock') -PathType Leaf)) {
    Write-Host 'error: pyproject.toml があるのに uv.lock がありません。'
    Write-Host '  (topics/PYTHON_DEV_ENV.md: uv.lock をリポジトリに含め、再現性を担保する)'
    $status = 1
}

exit $status
