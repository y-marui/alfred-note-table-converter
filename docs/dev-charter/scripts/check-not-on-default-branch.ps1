#!/usr/bin/env pwsh
# PowerShell counterpart of check-not-on-default-branch.sh (same behavior).
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if ($env:CI) { exit 0 }

# rev-parse --abbrev-ref HEAD fails on an unborn HEAD (before the first
# commit). symbolic-ref returns the branch HEAD points to regardless of
# whether it has a commit yet, so this also catches the initial commit
# during new-repo setup. A detached HEAD makes symbolic-ref itself fail,
# which is safely skipped below.
$branch = (git symbolic-ref --short HEAD 2>$null)
if (-not $branch) { exit 0 }

$defaultBranch = $null
git remote get-url origin *> $null
if ($LASTEXITCODE -eq 0) {
    $ref = (git symbolic-ref --short refs/remotes/origin/HEAD 2>$null)
    if ($ref) { $defaultBranch = $ref -replace '^origin/', '' }
}

if ($branch -eq 'main' -or $branch -eq 'master' -or ($defaultBranch -and $branch -eq $defaultBranch)) {
    # 表示用にホームディレクトリ配下のパスは ~ に短縮する
    # （no-hardcoded-local-paths と同様、絶対パスをそのまま出さない配慮）。
    $scriptDir = $PSScriptRoot
    if ($HOME -and $scriptDir -eq $HOME) {
        $scriptDir = '~'
    } elseif ($HOME -and $scriptDir.StartsWith($HOME + [System.IO.Path]::DirectorySeparatorChar)) {
        $scriptDir = '~' + $scriptDir.Substring($HOME.Length)
    }
    Write-Host "error: デフォルトブランチ (${branch}) への直接コミットはブロックされています。"
    Write-Host "  次のコマンドでブランチを作成してそちらに移動してください: pwsh $scriptDir/new-branch.ps1 <branch-name>"
    Write-Host '  （ステージ済み・未ステージの変更はそのまま新ブランチに引き継がれます）'
    exit 1
}

exit 0
