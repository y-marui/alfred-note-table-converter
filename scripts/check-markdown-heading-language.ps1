#!/usr/bin/env pwsh
# PowerShell counterpart of check-markdown-heading-language.sh (same behavior).
#
# Unlike the bash version, this doesn't need a perl workaround for the CJK
# character-class detection: .NET regex handles Unicode codepoint ranges
# correctly on every platform pwsh runs on.
#
# Usage:
#   pwsh scripts/check-markdown-heading-language.ps1 [file.md ...]
#   (no args: scans all *.md files under the repo, excluding .git/)
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Files
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not $Files -or $Files.Count -eq 0) {
    $Files = Get-ChildItem -Path '.' -Recurse -Filter '*.md' -File |
        Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' } |
        ForEach-Object { $_.FullName }
}

$japanesePattern = '[ぁ-んァ-ヶ一-龠々ー]'
$openingFencePattern = '^[ \t]{0,3}(`{3,}|~{3,})'
$status = 0

foreach ($file in $Files) {
    $fenceChar = ''
    $fenceLength = 0
    $lineNumber = 0
    $previousLine = ''
    $previousLineNumber = 0

    foreach ($line in Get-Content -Path $file) {
        $lineNumber++

        if (-not $fenceChar -and $line -match $openingFencePattern) {
            $marker = $Matches[1]
            $fenceChar = $marker.Substring(0, 1)
            $fenceLength = $marker.Length
            $previousLine = ''
            $previousLineNumber = 0
            continue
        }

        if ($fenceChar) {
            $closingFencePattern = "^[ \t]{0,3}$([regex]::Escape($fenceChar)){$fenceLength,}[ \t]*`$"
            if ($line -match $closingFencePattern) {
                $fenceChar = ''
                $fenceLength = 0
            }
            continue
        }

        if ($line -match '^[ \t]{0,3}#{2,6}[ \t]' -and $line -match $japanesePattern) {
            Write-Host "${file}:${lineNumber}: section headings must be written in English: $line"
            $status = 1
        }

        if ($line -match '^[ \t]{0,3}-+[ \t]*$' -and $previousLine -and $previousLine -match $japanesePattern) {
            Write-Host "${file}:${previousLineNumber}: section headings must be written in English: $previousLine"
            $status = 1
        }

        if ($line.Trim()) {
            $previousLine = $line
            $previousLineNumber = $lineNumber
        } else {
            $previousLine = ''
            $previousLineNumber = 0
        }
    }
}

exit $status
