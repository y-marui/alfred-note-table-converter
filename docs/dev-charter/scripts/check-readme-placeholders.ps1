#!/usr/bin/env pwsh
# PowerShell counterpart of check-readme-placeholders.sh (same behavior).
# topics/PROJECT_README_GUIDELINES.md: 配布用ファイル（LICENSE・
# .github/FUNDING.yml・README）に残ったプレースホルダ（[YEAR] [AUTHOR]
# [USERNAME] [BMC_USERNAME]）を機械的に検証する。
#
# {user}/{repo}/{workflow}（CI バッジ）は対象外にする: dev-charter 自身の
# README.md が「採用先への導入方法の説明」としてこれらの文字列を意図的に
# 使っており、コードブロック解析なしでは確実に区別できないため。
#
# README_TEMPLATE.md が存在するリポジトリはテンプレートリポジトリ自体
# であり、これらのプレースホルダは意図的に残す（
# topics/GITHUB_SETTINGS.md, topics/TEMPLATE_README_GUIDELINES.md 参照）
# ため対象外。
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = (git rev-parse --show-toplevel).Trim()

if (Test-Path (Join-Path $repoRoot 'README_TEMPLATE.md') -PathType Leaf) { exit 0 }
if (Test-Path (Join-Path $repoRoot 'README_TEMPLATE-jp.md') -PathType Leaf) { exit 0 }

$status = 0

function Test-FilePlaceholders {
    param($file, $patterns)
    $path = Join-Path $repoRoot $file
    if (-not (Test-Path $path -PathType Leaf)) { return }

    $content = Get-Content $path -Raw
    foreach ($pattern in $patterns) {
        if ($content.Contains($pattern)) {
            Write-Host "error: ${file} にプレースホルダ ${pattern} が残っています。"
            Write-Host '  (topics/PROJECT_README_GUIDELINES.md: プレースホルダを実際の値に置換する)'
            $script:status = 1
        }
    }
}

Test-FilePlaceholders -file 'LICENSE' -patterns @('[YEAR]', '[AUTHOR]')
Test-FilePlaceholders -file '.github/FUNDING.yml' -patterns @('[USERNAME]', '[BMC_USERNAME]')
Test-FilePlaceholders -file 'README.md' -patterns @('[USERNAME]', '[BMC_USERNAME]')
Test-FilePlaceholders -file 'README-jp.md' -patterns @('[USERNAME]', '[BMC_USERNAME]')

exit $status
