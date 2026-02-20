# JUNO Sync - bidirectional pool sync
# Dot-sourced by PowerShell profile. Provides juno-pull and juno-push globally.
#
# One-time setup (run once per machine):
#   Add-Content $PROFILE "`n. 'E:\Projects\juno-ai\sync.ps1'"
#
# Usage from any project root:
#   juno-pull                    pull latest pool from juno-ai --> current project
#   juno-push                    push pool from current project --> juno-ai + commit + push
#   juno-export [OutputPath]     export pool to a local folder or zip (no GitHub needed)
#   juno-import <SourcePath>     import pool from a local folder or zip into current project

$JUNO_POOL = "E:\Projects\juno-ai"
$JUNO_GITHUB = "$JUNO_POOL\.github"
$POOL_FOLDERS = @("agents", "skills", "prompts", "instructions", "diagrams")

function juno-pull {
    param([string]$ProjectRoot = (Get-Location).Path)

    $target = Join-Path $ProjectRoot ".github"

    if (-not (Test-Path $target)) {
        Write-Host "No .github/ folder found at $ProjectRoot" -ForegroundColor Red
        Write-Host "Are you in a project root?" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "  JUNO PULL  juno-ai --> $(Split-Path $ProjectRoot -Leaf)" -ForegroundColor Cyan
    Write-Host "  -----------------------------------------" -ForegroundColor DarkGray

    foreach ($folder in $POOL_FOLDERS) {
        $src = Join-Path $JUNO_GITHUB $folder
        if (Test-Path $src) {
            Copy-Item $src $target -Recurse -Force
            Write-Host "  [OK]  $folder" -ForegroundColor Green
        } else {
            Write-Host "  [--]  $folder - not found in pool, skipped" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "  Done. project-config.md was NOT overwritten." -ForegroundColor DarkGray
    Write-Host ""
}

function juno-push {
    param(
        [string]$ProjectRoot = (Get-Location).Path,
        [string]$Message = ""
    )

    $source = Join-Path $ProjectRoot ".github"

    if (-not (Test-Path $source)) {
        Write-Host "No .github/ folder found at $ProjectRoot" -ForegroundColor Red
        Write-Host "Are you in a project root?" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "  JUNO PUSH  $(Split-Path $ProjectRoot -Leaf) --> juno-ai" -ForegroundColor Magenta
    Write-Host "  -----------------------------------------" -ForegroundColor DarkGray

    foreach ($folder in $POOL_FOLDERS) {
        $src = Join-Path $source $folder
        if (Test-Path $src) {
            Copy-Item $src $JUNO_GITHUB -Recurse -Force
            Write-Host "  [OK]  $folder" -ForegroundColor Green
        } else {
            Write-Host "  [--]  $folder - not in project, skipped" -ForegroundColor DarkGray
        }
    }

    # Commit and push juno-ai
    Push-Location $JUNO_POOL

    $hasChanges = (git status --porcelain) -ne $null
    if (-not $hasChanges) {
        Write-Host ""
        Write-Host "  No changes detected in juno-ai. Nothing to commit." -ForegroundColor DarkGray
        Pop-Location
        return
    }

    git add .github/agents .github/skills .github/prompts .github/instructions .github/diagrams | Out-Null

    if ([string]::IsNullOrWhiteSpace($Message)) {
        $projectName = Split-Path $ProjectRoot -Leaf
        $today = Get-Date -Format "yyyy-MM-dd"
        $Message = "feat: sync pool from $projectName - $today"
    }

    git commit -m $Message | Out-Null
    git push | Out-Null

    Pop-Location

    Write-Host ""
    Write-Host "  Committed and pushed to juno-ai." -ForegroundColor Magenta
    Write-Host ""
}

function juno-export {
    # Exports the AI resource pool to a self-contained local folder or zip.
    # Use this when the target machine has no GitHub access.
    #
    # Usage:
    #   juno-export                          # exports to .\juno-ai-pool-export\
    #   juno-export -OutputPath C:\USB\juno  # exports to specific path
    #   juno-export -Zip                     # exports to .\juno-ai-pool-export.zip
    param(
        [string]$OutputPath = (Join-Path (Get-Location).Path "juno-ai-pool-export"),
        [switch]$Zip
    )

    $date = Get-Date -Format "yyyy-MM-dd"
    $zipPath = "$OutputPath-$date.zip"

    if ($Zip) {
        $OutputPath = Join-Path ([System.IO.Path]::GetTempPath()) "juno-ai-pool-export-tmp"
    }

    if (Test-Path $OutputPath) { Remove-Item $OutputPath -Recurse -Force }
    New-Item -ItemType Directory -Path $OutputPath | Out-Null

    Write-Host ""
    Write-Host "  JUNO EXPORT  juno-ai --> $OutputPath" -ForegroundColor Cyan
    Write-Host "  -----------------------------------------" -ForegroundColor DarkGray

    foreach ($folder in $POOL_FOLDERS) {
        $src = Join-Path $JUNO_GITHUB $folder
        if (Test-Path $src) {
            Copy-Item $src $OutputPath -Recurse -Force
            Write-Host "  [OK]  $folder" -ForegroundColor Green
        } else {
            Write-Host "  [--]  $folder - not found, skipped" -ForegroundColor Yellow
        }
    }

    # Include the sync script itself so the target can dot-source it
    Copy-Item (Join-Path $JUNO_POOL "sync.ps1") $OutputPath -Force
    Write-Host "  [OK]  sync.ps1" -ForegroundColor Green

    if ($Zip) {
        Compress-Archive -Path "$OutputPath\*" -DestinationPath $zipPath -Force
        Remove-Item $OutputPath -Recurse -Force
        Write-Host ""
        Write-Host "  Exported to: $zipPath" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "  Exported to: $OutputPath" -ForegroundColor Cyan
    }

    Write-Host "  On the target machine, run:" -ForegroundColor DarkGray
    Write-Host "    juno-import <path-to-export-folder>   # from any project root" -ForegroundColor DarkGray
    Write-Host ""
}

function juno-import {
    # Imports AI resource pool from a local export folder (created by juno-export).
    # Use this on machines with no GitHub access.
    #
    # Usage (run from the target project root):
    #   juno-import C:\USB\juno-ai-pool-export
    #   juno-import C:\USB\juno-ai-pool-export-2026-02-20.zip
    param(
        [Parameter(Mandatory)][string]$SourcePath,
        [string]$ProjectRoot = (Get-Location).Path
    )

    $target = Join-Path $ProjectRoot ".github"

    if (-not (Test-Path $target)) {
        Write-Host "No .github/ folder found at $ProjectRoot" -ForegroundColor Red
        Write-Host "Are you in a project root?" -ForegroundColor Yellow
        return
    }

    # Handle zip input
    $tmpExtract = $null
    if ($SourcePath -match '\.zip$') {
        $tmpExtract = Join-Path ([System.IO.Path]::GetTempPath()) "juno-import-tmp"
        if (Test-Path $tmpExtract) { Remove-Item $tmpExtract -Recurse -Force }
        Expand-Archive -Path $SourcePath -DestinationPath $tmpExtract
        $SourcePath = $tmpExtract
    }

    if (-not (Test-Path $SourcePath)) {
        Write-Host "Source path not found: $SourcePath" -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "  JUNO IMPORT  $SourcePath --> $(Split-Path $ProjectRoot -Leaf)" -ForegroundColor Cyan
    Write-Host "  -----------------------------------------" -ForegroundColor DarkGray

    foreach ($folder in $POOL_FOLDERS) {
        $src = Join-Path $SourcePath $folder
        if (Test-Path $src) {
            Copy-Item $src $target -Recurse -Force
            Write-Host "  [OK]  $folder" -ForegroundColor Green
        } else {
            Write-Host "  [--]  $folder - not in export, skipped" -ForegroundColor Yellow
        }
    }

    if ($tmpExtract -and (Test-Path $tmpExtract)) {
        Remove-Item $tmpExtract -Recurse -Force
    }

    Write-Host ""
    Write-Host "  Done. project-config.md was NOT overwritten." -ForegroundColor DarkGray
    Write-Host "  Remember to create/update copilot-instructions.md for this project." -ForegroundColor DarkGray
    Write-Host ""
}
