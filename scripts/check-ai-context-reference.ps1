#!/usr/bin/env pwsh
# PowerShell counterpart of check-ai-context-reference.sh (same behavior).
# AI_TOOL_SETUP.md: "AI ツールごとの設定ファイルは AI_CONTEXT.md への参照のみを
# 持ち、ツール固有の設定のみを追記する。AI_CONTEXT.md の内容は重複させない。"
# を機械的に検証する（参照の有無のみ。重複の有無は判定しない）。
#
# AI_CONTEXT.md が無いプロジェクト（未導入 or 導入前）は対象外。
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = (git rev-parse --show-toplevel).Trim()

if (-not (Test-Path (Join-Path $repoRoot 'AI_CONTEXT.md') -PathType Leaf)) { exit 0 }

$status = 0
foreach ($f in 'CLAUDE.md', 'GEMINI.md', 'AGENTS.md', '.github/copilot-instructions.md') {
    $path = Join-Path $repoRoot $f
    if (-not (Test-Path $path -PathType Leaf)) { continue }
    $content = Get-Content $path -Raw
    if ($content -notmatch 'AI_CONTEXT\.md') {
        Write-Host "error: ${f} が AI_CONTEXT.md を参照していません（AI_TOOL_SETUP.md）"
        $status = 1
    }
}

exit $status
