#!/usr/bin/env pwsh
# PowerShell counterpart of check-language-pair-footer.sh (same behavior).
# LANGUAGE_POLICY.md: 日英ペアドキュメントの冒頭宣言（正本/参照）・末尾の
# 編集ルールフッターの有無を機械的に検証する。
#
# 文言は完全一致を要求せず、キーワードの有無で緩く判定する。
# 対象はペアが両方存在するドキュメントのみ。
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$status = 0

function Test-Pair {
    param($jp, $en)

    $headJp = (Get-Content $jp -TotalCount 5) -join "`n"
    $tailJp = (Get-Content $jp | Select-Object -Last 5) -join "`n"
    $headEn = (Get-Content $en -TotalCount 5) -join "`n"
    $tailEn = (Get-Content $en | Select-Object -Last 5) -join "`n"

    if ($headJp -notmatch '正本') {
        Write-Host "error: ${jp} の冒頭に正本宣言がありません（LANGUAGE_POLICY.md）"
        $script:status = 1
    }
    if (-not ($tailJp -match '英語版' -and $tailJp -match '同一コミット|同じコミット')) {
        Write-Host "error: ${jp} の末尾に編集ルールフッター（英語版があり同一コミットで更新する旨）がありません（LANGUAGE_POLICY.md）"
        $script:status = 1
    }
    if ($headEn -notmatch '(?i)canonical|reference') {
        Write-Host "error: ${en} の冒頭に参照宣言がありません（LANGUAGE_POLICY.md）"
        $script:status = 1
    }
    if (-not ($tailEn -match '(?i)canonical' -and $tailEn -match '(?i)same commit')) {
        Write-Host "error: ${en} の末尾に編集ルールフッター（正本があり同一コミットで更新する旨）がありません（LANGUAGE_POLICY.md）"
        $script:status = 1
    }
}

$jpFiles = git ls-files -- '*-jp.md'
foreach ($jp in ($jpFiles -split "`n" | Where-Object { $_ -ne '' })) {
    if ($jp -match '^(?<base>.+)-jp\.(?<ext>[^./]+)$') {
        $en = "$($Matches.base).$($Matches.ext)"
        if (Test-Path $en -PathType Leaf) {
            Test-Pair -jp $jp -en $en
        }
    }
}

exit $status
