#!/usr/bin/env pwsh
# PowerShell counterpart of check-hook-scripts.sh (same behavior, except that
# the executable-bit check is skipped: it has no meaning on Windows).
# SECURITY_POLICY.md: .pre-commit-config.yaml の entry が指すスクリプトが
# 実在するか、およびフックと対で導入する補助スクリプトが揃っているかを
# 機械的に検証する。.pre-commit-config.yaml が無いプロジェクトは対象外。
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = (git rev-parse --show-toplevel).Trim()
$config = Join-Path $repoRoot '.pre-commit-config.yaml'

if (-not (Test-Path $config -PathType Leaf)) { exit 0 }

# フックスクリプト = 対で導入する補助スクリプト
$pairs = @{ 'check-not-on-default-branch.sh' = 'new-branch.sh' }

$status = 0
$referenced = @()

foreach ($line in Get-Content $config) {
    if ($line -notmatch '^\s*entry:\s*(.*)$') { continue }
    $entry = ($Matches[1] -replace '#.*$', '').Trim()
    if (-not $entry) { continue }
    $script = ($entry -split '\s+')[0].Trim('"', "'")
    if ($script -notmatch '/.*\.sh$') { continue }
    $referenced += $script
    if (-not (Test-Path (Join-Path $repoRoot $script) -PathType Leaf)) {
        Write-Host "error: .pre-commit-config.yaml が指す ${script} が存在しません（SECURITY_POLICY.md）"
        $status = 1
    }
}

foreach ($hook in $pairs.Keys) {
    $helper = $pairs[$hook]
    foreach ($script in $referenced) {
        if ((Split-Path $script -Leaf) -ne $hook) { continue }
        $dir = Split-Path $script -Parent
        $helperPath = if ($dir) { "$dir/$helper" } else { $helper }
        if (-not (Test-Path (Join-Path $repoRoot $helperPath) -PathType Leaf)) {
            Write-Host "error: ${hook} と対で導入する ${helperPath} が存在しません（SECURITY_POLICY.md）"
            $status = 1
        }
    }
}

exit $status
