#!/usr/bin/env pwsh
# Lint the given PowerShell scripts with PSScriptAnalyzer, installing the
# module on first run if it isn't already available.
#
# Local-only check (see .pre-commit-config.yaml / ci.yml SKIP): not required
# to gate merges, it exists for parity with the Linux/macOS shellcheck
# coverage while the Windows-facing scripts under scripts/ are PowerShell.
#
# Usage:
#   pwsh scripts/check-powershell-lint.ps1 <file1.ps1> [file2.ps1 ...]
$ErrorActionPreference = 'Stop'

$files = $args
if ($files.Count -eq 0) {
    exit 0
}

if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Host 'Installing PSScriptAnalyzer (first run)...'
    Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force -ErrorAction Stop
}

$settingsFile = Join-Path $PSScriptRoot 'PSScriptAnalyzerSettings.psd1'

$hasIssues = $false
foreach ($file in $files) {
    $results = Invoke-ScriptAnalyzer -Path $file -Severity Warning, Error -Settings $settingsFile
    foreach ($result in $results) {
        Write-Host ("{0}:{1}: {2} ({3})" -f $file, $result.Line, $result.Message, $result.RuleName)
        $hasIssues = $true
    }
}

if ($hasIssues) {
    exit 1
}
exit 0
