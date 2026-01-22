# Update claude-md-luau submodules across all repos in ~/git
# Windows PowerShell version

param(
    [switch]$Commit,
    [switch]$Push,
    [switch]$DryRun,
    [switch]$Help,
    [string]$GitDir = (Join-Path $env:USERPROFILE "git"),
    [string]$SubmodulePath = "Submodules/claude-md-luau"
)

$ErrorActionPreference = "Continue"

function Write-Color {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

if ($Help) {
    Write-Host "Usage: update-submodules.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Commit       Commit submodule updates"
    Write-Host "  -Push         Commit and push submodule updates"
    Write-Host "  -DryRun       Show what would be updated without making changes"
    Write-Host "  -GitDir       Directory containing git repos (default: ~/git)"
    Write-Host "  -SubmodulePath Path to submodule within repos (default: Submodules/claude-md-luau)"
    Write-Host "  -Help         Show this help message"
    exit 0
}

if ($Push) { $Commit = $true }

Write-Color "Update claude-md-luau Submodules" "Cyan"
Write-Host "=========================================="
Write-Host "Scanning: $GitDir"
Write-Host "Submodule path: $SubmodulePath"
Write-Host ""

$updatedRepos = @()
$skippedRepos = @()
$failedRepos = @()

# Find repos with the submodule
$repos = @()
Get-ChildItem -Path $GitDir -Directory | ForEach-Object {
    $repoPath = $_.FullName
    $repoName = $_.Name

    # Skip claude-md-luau itself
    if ($repoName -eq "claude-md-luau") { return }

    # Check if it's a git repo
    if (-not (Test-Path (Join-Path $repoPath ".git"))) { return }

    # Check for .gitmodules with our submodule
    $gitModules = Join-Path $repoPath ".gitmodules"
    if ((Test-Path $gitModules) -and ((Get-Content $gitModules -Raw) -match "claude-md-luau")) {
        $repos += $repoPath
    }
}

if ($repos.Count -eq 0) {
    Write-Host "No repos found with claude-md-luau submodule"
    exit 0
}

Write-Host "Found $($repos.Count) repo(s) with submodule"
Write-Host ""

foreach ($repo in $repos) {
    $repoName = Split-Path $repo -Leaf
    Write-Color "  Processing: $repoName" "Cyan"

    Push-Location $repo
    try {
        $submoduleDir = Join-Path $repo $SubmodulePath

        # Check if submodule directory exists
        if (-not (Test-Path $submoduleDir)) {
            Write-Color "    Submodule directory not found, initializing..." "Yellow"
            if ($DryRun) {
                Write-Color "    [DRY RUN] Would initialize submodule" "Yellow"
                $skippedRepos += "$repoName (dry run)"
                continue
            }
            git submodule update --init $SubmodulePath 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Color "    Failed to initialize submodule" "Red"
                $failedRepos += "$repoName (init failed)"
                continue
            }
        }

        # Get current commit
        Push-Location $submoduleDir
        $oldCommit = git rev-parse HEAD 2>$null
        Pop-Location

        if ($DryRun) {
            # Fetch to see what would change
            Push-Location $submoduleDir
            git fetch origin main 2>$null
            $newCommit = git rev-parse origin/main 2>$null
            Pop-Location

            if ($oldCommit -ne $newCommit) {
                Write-Color "    [DRY RUN] Would update from $($oldCommit.Substring(0,7)) to $($newCommit.Substring(0,7))" "Yellow"
                $updatedRepos += "$repoName (dry run)"
            } else {
                Write-Color "    Already up to date" "Green"
                $skippedRepos += "$repoName (up to date)"
            }
            continue
        }

        # Actually update
        git submodule update --remote --merge $SubmodulePath 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Color "    Failed to update submodule" "Red"
            $failedRepos += "$repoName (update failed)"
            continue
        }

        # Get new commit
        Push-Location $submoduleDir
        $newCommit = git rev-parse HEAD 2>$null
        Pop-Location

        if ($oldCommit -ne $newCommit) {
            Write-Color "    Updated from $($oldCommit.Substring(0,7)) to $($newCommit.Substring(0,7))" "Green"
            $updatedRepos += $repoName

            if ($Commit) {
                git add $SubmodulePath
                git commit -m "Update claude-md-luau submodule" 2>$null

                if ($Push) {
                    Write-Color "    Pushing..." "Cyan"
                    git push 2>$null
                    if ($LASTEXITCODE -ne 0) {
                        Write-Color "    Push failed (may need PR)" "Yellow"
                    }
                }
            }
        } else {
            Write-Color "    Already up to date" "Green"
            $skippedRepos += "$repoName (up to date)"
        }
    }
    finally {
        Pop-Location
    }
}

# Summary
Write-Host ""
Write-Color "Summary" "Cyan"
Write-Host "=========================================="

if ($updatedRepos.Count -gt 0) {
    Write-Color "Updated ($($updatedRepos.Count)):" "Green"
    $updatedRepos | ForEach-Object { Write-Host "  - $_" }
}

if ($skippedRepos.Count -gt 0) {
    Write-Color "Skipped ($($skippedRepos.Count)):" "Yellow"
    $skippedRepos | ForEach-Object { Write-Host "  - $_" }
}

if ($failedRepos.Count -gt 0) {
    Write-Color "Failed ($($failedRepos.Count)):" "Red"
    $failedRepos | ForEach-Object { Write-Host "  - $_" }
}

Write-Host ""
Write-Color "Done!" "Green"
