#!/usr/bin/env pwsh
# PowerShell counterpart of check-language-pair-sync.sh (same behavior).
# LANGUAGE_POLICY.md: "日本語版と英語版は同一コミットで更新する" を機械的に
# 検証する（同ポリシー: "構文・差分から判定できる項目は機械的に検証してよい"）。
#
# ペアは命名規則で判定する: <name>-jp.<ext> が正本（日本語）、<name>.<ext> が
# 参照（英語）。ペアの一方だけがステージされ、もう一方がリポジトリに存在する
# のに変更されていない場合はエラーにする。
#
# 例外: 変更が冒頭の正本/参照宣言と末尾の編集ルールフッター（LANGUAGE_POLICY.md
# "When Using Separate Files"）だけの場合は、対になるファイルの更新を求めない。
# 宣言・フッターを標準文に揃える修正は、片側だけが基準からずれている場合に
# もう一方へ意味のない編集を入れさせないための例外（内容の変更は従来どおり
# 同一コミットを要求する）。
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Markdown の行配列から、冒頭の宣言（先頭 8 行以内の引用ブロックで、
# 正本/参照/canonical/reference を含むもの）、末尾 6 行以内の `---` 以降の
# フッター（同一コミット/same commit を含むもの）、空行を除いた行を返す。
function Get-StrippedLines([string[]]$Lines) {
    $n = $Lines.Count
    $a = -1; $b = -1; $f = -1
    for ($i = 0; $i -lt $n -and $i -lt 8; $i++) {
        if ($Lines[$i] -match '^>') { $a = $i; break }
    }
    if ($a -ge 0) {
        $b = $a
        while ($b + 1 -lt $n -and $Lines[$b + 1] -match '^>') { $b++ }
        $blk = ($Lines[$a..$b]) -join ''
        if ($blk -notmatch '正本|参照|(?i:canonical)|(?i:reference)') { $a = -1; $b = -1 }
    }
    for ($i = $n - 1; $i -ge 0 -and $i -ge $n - 6; $i--) {
        if ($Lines[$i] -eq '---') { $f = $i; break }
    }
    if ($f -ge 0) {
        $ft = ($Lines[$f..($n - 1)]) -join ''
        if ($ft -notmatch '同一コミット|同じコミット|(?i:same commit)') { $f = -1 }
    }
    for ($i = 0; $i -lt $n; $i++) {
        if ($a -ge 0 -and $i -ge $a -and $i -le $b) { continue }
        if ($f -ge 0 -and $i -ge $f) { continue }
        if ($Lines[$i] -match '^\s*$') { continue }
        $Lines[$i]
    }
}

# ステージされた変更が宣言・フッターだけなら $true（HEAD に無い新規ファイルは $false）。
function Test-OnlyMarkersChanged([string]$File) {
    git cat-file -e "HEAD:$File" 2>$null
    if ($LASTEXITCODE -ne 0) { return $false }
    $old = @(Get-StrippedLines (@(git show "HEAD:$File") -split "`n")) -join "`n"
    $new = @(Get-StrippedLines (@(git show ":$File") -split "`n")) -join "`n"
    return $old -ceq $new
}

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
    if (Test-OnlyMarkersChanged $file) { continue }

    Write-Host "error: ${file} を変更していますが、対になる ${pair} が同一コミットで更新されていません。"
    Write-Host '  (LANGUAGE_POLICY.md: 日本語版と英語版は同一コミットで更新する)'
    $status = 1
}

exit $status
