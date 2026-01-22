# Claude Workflow Sync Script for Windows PowerShell
# Syncs the claude-md-luau repository and updates all installations

param(
    [switch]$Pull,
    [switch]$Push,
    [switch]$Claude,
    [switch]$Submodules,
    [switch]$All,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Get script directory
$ScriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Write-Color {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

Write-Color "Claude Workflow Sync" "Cyan"
Write-Host "=========================================="
Write-Host "Repository: $ScriptDir"
Write-Host ""

if ($Help) {
    Write-Host "Usage: sync.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Pull        Pull changes only (default behavior)"
    Write-Host "  -Push        Push local changes after pulling"
    Write-Host "  -Claude      Use Claude to help resolve merge conflicts"
    Write-Host "  -Submodules  Update submodules in ~/git projects"
    Write-Host "  -All         Run full sync (pull, push, submodules)"
    Write-Host "  -Help        Show this help message"
    exit 0
}

if ($All) {
    $Push = $true
    $Submodules = $true
}

# Change to repo directory
Push-Location $ScriptDir

try {
    # Check for local changes
    function Test-LocalChanges {
        $status = git status --porcelain
        return [bool]$status
    }

    # Stash changes if needed
    $stashed = $false
    if (Test-LocalChanges) {
        Write-Color "Stashing local changes..." "Yellow"
        git stash push -m "sync-script-$(Get-Date -Format 'yyyyMMddHHmmss')"
        $stashed = $true
    }

    # Pull changes
    Write-Color "Pulling latest changes..." "Cyan"
    git fetch origin

    $behind = (git rev-list HEAD..origin/main --count 2>$null) -as [int]
    $ahead = (git rev-list origin/main..HEAD --count 2>$null) -as [int]

    if ($behind -eq 0) {
        Write-Color "Already up to date" "Green"
    } else {
        Write-Host "  Behind by $behind commit(s), ahead by $ahead commit(s)"

        $pullResult = git pull --rebase origin main 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Color "Merge conflict detected" "Yellow"

            if ($Claude) {
                Write-Color "Invoking Claude to resolve conflicts..." "Cyan"

                $claudeCmd = Get-Command "claude" -ErrorAction SilentlyContinue
                if (-not $claudeCmd) {
                    Write-Color "Claude CLI not found. Please resolve conflicts manually." "Red"
                    throw "Claude not available"
                }

                $conflicts = git diff --name-only --diff-filter=U
                $prompt = @"
Please resolve the merge conflicts in these files:
$conflicts

Current git status:
$(git status)

For each file, analyze both versions and choose the most appropriate resolution.
"@
                $prompt | claude --print

                # Check if conflicts resolved
                $remaining = git diff --name-only --diff-filter=U
                if ($remaining) {
                    Write-Color "Some conflicts remain unresolved" "Red"
                    throw "Conflicts not resolved"
                }

                git rebase --continue
                Write-Color "Conflicts resolved with Claude's help" "Green"
            } else {
                Write-Color "Please resolve conflicts manually or use -Claude flag" "Red"
                Write-Host ""
                Write-Host "Conflicted files:"
                git diff --name-only --diff-filter=U
                throw "Merge conflicts"
            }
        }

        Write-Color "Pull successful" "Green"
    }

    # Push changes if requested
    if ($Push) {
        if ($stashed) {
            Write-Color "Restoring stashed changes..." "Yellow"
            git stash pop
            $stashed = $false
        }

        Write-Color "Pushing changes..." "Cyan"
        $ahead = (git rev-list origin/main..HEAD --count 2>$null) -as [int]

        if ($ahead -eq 0) {
            Write-Color "Nothing to push" "Green"
        } else {
            Write-Host "  Pushing $ahead commit(s)..."
            git push origin main
            if ($LASTEXITCODE -eq 0) {
                Write-Color "Push successful" "Green"
            } else {
                Write-Color "Push failed" "Red"
            }
        }
    }

    # Restore stash if needed
    if ($stashed) {
        Write-Color "Restoring stashed changes..." "Yellow"
        git stash pop
    }

    # Update system files
    Write-Color "Updating system files..." "Cyan"

    $CommandsDir = Join-Path $env:USERPROFILE ".claude" "commands"
    $SourceCommands = Join-Path $ScriptDir "commands"

    Get-ChildItem -Path $SourceCommands -Filter "*.md" | ForEach-Object {
        $target = Join-Path $CommandsDir $_.Name

        if (-not (Test-Path $target)) {
            try {
                New-Item -ItemType SymbolicLink -Path $target -Target $_.FullName -Force | Out-Null
                Write-Color "Created symlink: $($_.Name)" "Green"
            } catch {
                Copy-Item $_.FullName $target -Force
                Write-Color "Copied: $($_.Name)" "Yellow"
            }
        }
    }

    Write-Color "System files updated" "Green"

    # Update submodules if requested
    if ($Submodules) {
        Write-Color "Updating submodules in ~/git projects..." "Cyan"

        $gitDir = Join-Path $env:USERPROFILE "git"
        $count = 0

        Get-ChildItem -Path $gitDir -Directory | ForEach-Object {
            $repoPath = $_.FullName
            $gitModules = Join-Path $repoPath ".gitmodules"

            if ((Test-Path (Join-Path $repoPath ".git")) -and (Test-Path $gitModules)) {
                $content = Get-Content $gitModules -Raw
                if ($content -match "claude-md-luau") {
                    Write-Host "  Updating submodule in: $($_.Name)"
                    Push-Location $repoPath
                    try {
                        git submodule update --remote --merge Submodules/claude-md-luau 2>$null
                        $count++
                    } catch { }
                    Pop-Location
                }
            }
        }

        if ($count -eq 0) {
            Write-Host "  No repos with claude-md-luau submodule found"
        } else {
            Write-Color "Updated $count repo(s)" "Green"
        }
    }

    Write-Host ""
    Write-Color "Sync complete!" "Green"

} finally {
    Pop-Location
}
