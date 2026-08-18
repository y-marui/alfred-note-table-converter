#!/usr/bin/env pwsh
# dev-charter quick installer (PowerShell counterpart of install.sh)
#
# Usage:
#   irm https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.ps1 | iex
#
# Environment variables (all optional):
#   CHARTER_REMOTE   git remote name          (default: dev-charter)
#   CHARTER_URL      repository URL           (default: https://github.com/y-marui/dev-charter)
#   CHARTER_PREFIX   install directory        (default: docs/dev-charter)
#   CHARTER_BRANCH   branch to install from   (default: main)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$remoteName = if ($env:CHARTER_REMOTE) { $env:CHARTER_REMOTE } else { 'dev-charter' }
$remoteUrl = if ($env:CHARTER_URL) { $env:CHARTER_URL } else { 'https://github.com/y-marui/dev-charter' }
$prefix = if ($env:CHARTER_PREFIX) { $env:CHARTER_PREFIX } else { 'docs/dev-charter' }
$branch = if ($env:CHARTER_BRANCH) { $env:CHARTER_BRANCH } else { 'main' }

# 1. Verify we are inside a git repository
git rev-parse --git-dir *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error 'not in a git repository. Run this script from your project root.'
    exit 1
}

# 2. Skip if already installed
if (Test-Path $prefix) {
    Write-Host "dev-charter is already installed at $prefix."
    Write-Host 'To update, run:'
    Write-Host "  if (-not (git remote get-url $remoteName 2>`$null)) { git remote add $remoteName $remoteUrl }"
    Write-Host "  git subtree pull --prefix=$prefix $remoteName $branch --squash"
    exit 0
}

# 3. Add remote if not present
git remote get-url $remoteName *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Adding remote '$remoteName'..."
    git remote add $remoteName $remoteUrl
}

# 4. Fetch
Write-Host "Fetching $remoteName..."
git fetch $remoteName

# 5. Install via git subtree
Write-Host "Installing dev-charter to $prefix..."
git subtree add --prefix=$prefix $remoteName $branch --squash

# 6. Success message + prompt examples
Write-Host ''
Write-Host "dev-charter installed at $prefix"
Write-Host ''
Write-Host 'Next - paste this prompt into your AI tool (Claude Code, Copilot, Gemini, etc.):'
Write-Host ''
Write-Host "  $prefix/INSTALL_CHECKLIST.md を実行して"
Write-Host "  (English: Run $prefix/INSTALL_CHECKLIST.md)"
Write-Host ''

# 7. Offer to launch Claude Code if available
$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) {
    if (-not [Console]::IsInputRedirected) {
        $answer = Read-Host 'Launch Claude Code now to run the setup? [Y/n]'
        if ([string]::IsNullOrEmpty($answer) -or $answer -match '^[Yy]') {
            & claude "$prefix/INSTALL_CHECKLIST.md を実行して"
        } else {
            Write-Host ''
            Write-Host 'To start setup later, run:'
            Write-Host "  claude ""$prefix/INSTALL_CHECKLIST.md を実行して"""
        }
    } else {
        Write-Host 'Tip: launch Claude Code to start setup:'
        Write-Host "  claude ""$prefix/INSTALL_CHECKLIST.md を実行して"""
    }
}
