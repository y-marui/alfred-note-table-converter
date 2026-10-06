#!/usr/bin/env pwsh
# PowerShell counterpart of check-conventional-commit.sh (same behavior).
# PROJECT_LIFECYCLE.md: "コミットメッセージ：Conventional Commits形式
# （feat/fix/refactor/docs）" を機械的に検証する。
#
# 憲章の例示は feat/fix/refactor/docs の4種だが、Conventional Commits
# 仕様の標準セット（+chore/test/style/perf/build/ci）を広く許可する。
#
# merge コミットは対象外にする: pre-commit の commit-msg ステージには
# git commit-msg フックの第2引数（コミットソース）が渡らないため、
# 代わりにメッセージファイルのパス（マージ時は .git/MERGE_MSG）で判定する。
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$msgFile = $args[0]

if ((Split-Path $msgFile -Leaf) -in @('MERGE_MSG', 'SQUASH_MSG')) { exit 0 }

$firstLine = (Get-Content -Path $msgFile -TotalCount 1)
if ([string]::IsNullOrEmpty($firstLine)) { exit 0 }
if ($firstLine.TrimStart().StartsWith('#')) { exit 0 }
if ($firstLine -match '^Revert ') { exit 0 }

$pattern = '^(feat|fix|docs|refactor|chore|test|style|perf|build|ci)(\([a-zA-Z0-9_./-]+\))?!?: .+'
if ($firstLine -match $pattern) { exit 0 }

Write-Host "error: コミットメッセージが Conventional Commits 形式ではありません: ${firstLine}"
Write-Host '  (PROJECT_LIFECYCLE.md: コミットメッセージは Conventional Commits 形式)'
Write-Host '  例: feat: 新機能の説明 / fix: バグ修正の説明'
exit 1
