#!/usr/bin/env pwsh
# PowerShell counterpart of check-dotenv-gitignore.sh (same behavior).
# SECURITY_POLICY.md: ".env の正しい扱い方：.env は絶対にコミットしない。
# ダミー値のみを含む .env.example をコミットする。" を機械的に検証する。
#
# .env.example（または .env.sample / .env.template）がリポジトリに存在する
# のに .gitignore が .env を無視していない場合、開発者が誤って本物の .env を
# ステージしてしまうリスクが残るためエラーにする（コミット自体の検知は
# detect-dotenv フックが別途担う。これはその一次防御）。
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = (git rev-parse --show-toplevel).Trim()

$foundExample = $false
foreach ($name in '.env.example', '.env.sample', '.env.template') {
    if (Test-Path (Join-Path $repoRoot $name) -PathType Leaf) {
        $foundExample = $true
    }
}
if (-not $foundExample) { exit 0 }

$gitignore = Join-Path $repoRoot '.gitignore'
if (Test-Path $gitignore -PathType Leaf) {
    $hit = Get-Content $gitignore | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '\.env' }
    if ($hit) { exit 0 }
}

Write-Host 'error: .env.example 等が存在しますが、.gitignore に .env を無視するパターンがありません。'
Write-Host '  (SECURITY_POLICY.md: .env は絶対にコミットしない)'
Write-Host "  .gitignore に '.env' を追加してください。"
exit 1
