#!/usr/bin/env pwsh
# PowerShell counterpart of check-language-pair-sync.sh (same behavior).
# LANGUAGE_POLICY.md: "日本語版と英語版は同一コミットで更新する" を機械的に
# 検証する（同ポリシー: "構文・差分から判定できる項目は機械的に検証してよい"）。
#
# ペアは命名規則で判定する: <name>-jp.<ext> が正本（日本語）、<name>.<ext> が
# 参照（英語）。ペアの一方だけがステージされ、もう一方がリポジトリに存在する
# のに変更されていない場合はエラーにする。
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$changed = git diff --cached --name-only
if ([string]::IsNullOrEmpty($changed)) { exit 0 }
$changedList = $changed -split "`n" | Where-Object { $_ -ne '' }

$status = 0
foreach ($file in $changedList) {
    if ($file -match '^(?<base>.+)-jp\.(?<ext>[^./]+)$') {
        $pair = "$($Matches.base).$($Matches.ext)"
    }
    elseif ($file -match '^(?<base>.+)\.(?<ext>[^./]+)$') {
        $pair = "$($Matches.base)-jp.$($Matches.ext)"
    }
    else {
        continue
    }

    if ($pair -eq $file) { continue }

    git ls-files --error-unmatch $pair *>$null
    if ($LASTEXITCODE -ne 0) { continue }

    if ($changedList -contains $pair) { continue }

    Write-Host "error: ${file} を変更していますが、対になる ${pair} が同一コミットで更新されていません。"
    Write-Host '  (LANGUAGE_POLICY.md: 日本語版と英語版は同一コミットで更新する)'
    $status = 1
}

exit $status
