# sync-pool.ps1
# Pull latest AI resource pool from juno-ai into the current project.
# Run this from the ROOT of any project that uses the juno-ai pool.
#
# Usage:
#   cd E:\Projects\YourProject
#   E:\Projects\juno-ai\sync-pool.ps1

param(
    [string]$PoolPath = "E:\Projects\juno-ai\.github",
    [string]$ProjectGithub = ".\.github"
)

if (-not (Test-Path $PoolPath)) {
    Write-Error "Pool not found at: $PoolPath"
    exit 1
}

Write-Host "Syncing juno-ai pool -> $ProjectGithub ..." -ForegroundColor Cyan

foreach ($folder in @("agents", "skills", "prompts", "instructions", "diagrams")) {
    $src = Join-Path $PoolPath $folder
    if (Test-Path $src) {
        Copy-Item $src $ProjectGithub -Recurse -Force
        Write-Host "  ✓ $folder" -ForegroundColor Green
    } else {
        Write-Host "  - $folder (not found in pool, skipped)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Sync complete. project-config.md was NOT overwritten (intentional)." -ForegroundColor Cyan
