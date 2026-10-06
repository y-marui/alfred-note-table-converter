#!/usr/bin/env pwsh
# PowerShell counterpart of check-charter-ci-template.sh (same behavior).
# Compare this repo's .github/workflows/dev-charter-check.yml against the CI
# template documented in the installed dev-charter's README-jp.md
# ("## Version Check (CI)" section).
#
# - workflow file not present (optional feature not added yet) -> silent
# - installed dev-charter README missing (not installed here)  -> silent
# - template block not found in README-jp.md (README structure changed) -> warn only
# - workflow file differs from the template -> block
#
# Override with CHARTER_PREFIX env var if needed.
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = (git rev-parse --show-toplevel).Trim()
$prefix = if ($env:CHARTER_PREFIX) { $env:CHARTER_PREFIX } else { 'docs/dev-charter' }

$workflowFile = Join-Path $repoRoot '.github/workflows/dev-charter-check.yml'
$templateSource = Join-Path $repoRoot "$prefix/README-jp.md"

if (-not (Test-Path $workflowFile)) { exit 0 }
if (-not (Test-Path $templateSource)) { exit 0 }

$inSection = $false
$inBlock = $false
$template = [System.Collections.Generic.List[string]]::new()
foreach ($line in Get-Content -Path $templateSource) {
    if (-not $inSection -and $line -match '^## Version Check \(CI\)') {
        $inSection = $true
        continue
    }
    if ($inSection -and -not $inBlock -and $line -match '^```yaml') {
        $inBlock = $true
        continue
    }
    if ($inSection -and $inBlock -and $line -match '^```') {
        break
    }
    if ($inBlock) {
        $template.Add($line)
    }
}

if ($template.Count -eq 0) {
    Write-Warning "${templateSource} から CI テンプレートを抽出できませんでした（README 構成が変わった可能性があります）。"
    exit 0
}

$workflowLines = Get-Content -Path $workflowFile | ForEach-Object { $_ -replace "`r$", '' }

$diff = Compare-Object -ReferenceObject $template -DifferenceObject $workflowLines -SyncWindow ([int]::MaxValue)

if ($diff) {
    Write-Host "error: .github/workflows/dev-charter-check.yml が ${prefix}/README-jp.md の CI テンプレートと一致しません。"
    Write-Host ''
    foreach ($entry in $diff) {
        $marker = if ($entry.SideIndicator -eq '<=') { '- (template)' } else { '+ (workflow)' }
        Write-Host "$marker $($entry.InputObject)"
    }
    Write-Host ''
    Write-Host "  ${prefix}/README-jp.md の ""Version Check (CI)"" セクションを参照して更新してください。"
    exit 1
}

exit 0
