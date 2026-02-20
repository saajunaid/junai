# JUNO Sync - bidirectional pool sync
# Dot-sourced by PowerShell profile. Provides juno-pull and juno-push globally.
#
# One-time setup (run once per machine):
#   Add-Content $PROFILE "`n. 'E:\Projects\juno-ai\sync.ps1'"
#
# Usage from any project root:
#   juno-pull          pull latest pool from juno-ai --> current project
#   juno-push          push pool from current project --> juno-ai + commit + push

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
