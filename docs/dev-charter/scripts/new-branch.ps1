#!/usr/bin/env pwsh
# PowerShell counterpart of new-branch.sh (same behavior).
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if ($args.Count -ne 1 -or [string]::IsNullOrEmpty($args[0])) {
    Write-Host "usage: new-branch.ps1 <branch-name>"
    exit 1
}

$branchName = $args[0]

if ($branchName -in @('main', 'master', 'develop')) {
    Write-Host "error: '$branchName' は予約されたブランチ名です。別の名前を指定してください（例: work/<short-description>）。"
    exit 1
}

git checkout -b $branchName
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
Write-Host "ブランチ '$branchName' を作成し、そちらに移動しました。"
