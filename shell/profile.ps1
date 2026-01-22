# Claude Workflow PowerShell Profile
# Add the contents of this file to your $PROFILE or source it with:
# . "$env:USERPROFILE\git\claude-md-luau\shell\profile.ps1"

# ============================================================================
# Environment Setup
# ============================================================================

# Load environment variables from .env file
$envFile = Join-Path $env:USERPROFILE ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        # Skip empty lines and comments
        if ($line -and -not $line.StartsWith("#")) {
            $parts = $line -split "=", 2
            if ($parts.Count -eq 2) {
                $key = $parts[0].Trim()
                $value = $parts[1].Trim()
                # Remove surrounding quotes
                $value = $value -replace '^["'']|["'']$', ''
                [Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }
    }
}

# ============================================================================
# Git Utilities
# ============================================================================

function shipcheck {
    <#
    .SYNOPSIS
    Check if a repo has changes ready to ship
    #>

    # Verify we're in a git repo
    $gitDir = git rev-parse --git-dir 2>$null
    if (-not $gitDir) {
        Write-Host "Not a git repository"
        return
    }

    $hasIssues = $false

    # Check for uncommitted changes
    $staged = git diff --cached --quiet 2>$null
    $unstaged = git diff --quiet 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠ Uncommitted changes" -ForegroundColor Yellow
        $hasIssues = $true
    }

    # Check for untracked files
    $untracked = git ls-files --others --exclude-standard
    if ($untracked) {
        Write-Host "⚠ Untracked files" -ForegroundColor Yellow
        $hasIssues = $true
    }

    # Check for unpushed commits
    $unpushed = git log "@{u}..HEAD" --oneline 2>$null
    if ($unpushed) {
        Write-Host "⚠ Unpushed commits:" -ForegroundColor Yellow
        $unpushed | ForEach-Object { Write-Host "  $_" }
        $hasIssues = $true
    }

    # Check commits on main not in release
    $releaseExists = git show-ref --verify --quiet refs/remotes/origin/release 2>$null
    if ($LASTEXITCODE -eq 0) {
        $unreleased = git log origin/release..origin/main --oneline 2>$null
        if ($unreleased) {
            Write-Host "📦 Commits on main not in release:" -ForegroundColor Cyan
            $unreleased | ForEach-Object { Write-Host "  $_" }
            $hasIssues = $true
        }
    }

    # Check commits since latest tag
    $latestTag = git describe --tags --abbrev=0 2>$null
    if ($latestTag) {
        $sinceTag = git log "$latestTag..HEAD" --oneline 2>$null
        if ($sinceTag) {
            Write-Host "🏷 Commits since ${latestTag}:" -ForegroundColor Cyan
            $sinceTag | ForEach-Object { Write-Host "  $_" }
            $hasIssues = $true
        }
    }

    if (-not $hasIssues) {
        Write-Host "✓ Nothing to ship" -ForegroundColor Green
    }
}

function ghprc {
    <#
    .SYNOPSIS
    gh pr create wrapper that targets the origin remote repo
    #>
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )

    $originUrl = git remote get-url origin 2>$null
    if (-not $originUrl) {
        Write-Host "Error: Could not determine origin remote repository" -ForegroundColor Red
        return
    }

    # Extract owner/repo from URL
    $originRepo = $originUrl -replace '(git@github\.com:|https://github\.com/)', '' -replace '\.git$', ''

    gh pr create --repo $originRepo --assignee "@me" @Arguments
}

function genpass {
    <#
    .SYNOPSIS
    Generate a random password and copy to clipboard
    #>
    param(
        [int]$Length = 20
    )

    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-="
    $password = -join (1..$Length | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })

    Write-Host $password
    Set-Clipboard $password
    Write-Host "(Copied to clipboard)"
}

function mkrelease {
    <#
    .SYNOPSIS
    Create a release branch from main that merges release history
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Version
    )

    # Ensure we're on main and up to date
    git checkout main
    if ($LASTEXITCODE -ne 0) { return }
    git pull
    if ($LASTEXITCODE -ne 0) { return }

    # Create release branch from main
    $branch = "release-$Version"
    git checkout -b $branch
    if ($LASTEXITCODE -ne 0) { return }

    # Fetch release branch and merge it
    git fetch origin release
    git merge origin/release --no-edit -X ours
    if ($LASTEXITCODE -ne 0) { return }

    # Check if merge brought in unwanted changes
    $diff = git diff origin/main --stat
    if ($diff) {
        Write-Host "Merge brought in changes from release, resetting to main's versions..."
        $changedFiles = git diff origin/main --name-only
        foreach ($file in $changedFiles) {
            git checkout origin/main -- $file 2>$null
        }
        git add -A
        git commit --amend --no-edit
    }

    # Verify branch matches main
    $diff = git diff origin/main --stat
    if ($diff) {
        Write-Host "Error: Branch still differs from main:" -ForegroundColor Red
        Write-Host $diff
        return
    }

    Write-Host "✓ Created branch '$branch' matching main exactly" -ForegroundColor Green
    Write-Host "Push with: git push -u origin $branch"
    Write-Host "Then create PR: gh pr create --base release --title 'Release $Version'"
}

# ============================================================================
# Claude Session Management
# ============================================================================

$env:CLAUDE_SESSION_DIR = Join-Path $env:USERPROFILE ".claude-sessions"
$messagesDir = Join-Path $env:CLAUDE_SESSION_DIR "messages"
if (-not (Test-Path $env:CLAUDE_SESSION_DIR)) {
    New-Item -ItemType Directory -Path $env:CLAUDE_SESSION_DIR -Force | Out-Null
}
if (-not (Test-Path $messagesDir)) {
    New-Item -ItemType Directory -Path $messagesDir -Force | Out-Null
}

function claude-ls {
    <#
    .SYNOPSIS
    List all active Claude sessions
    #>
    Write-Host "Active Claude sessions:"
    Write-Host "─────────────────────────────────────────────────────────────────────"

    $found = $false
    $sessionFiles = Get-ChildItem -Path $env:CLAUDE_SESSION_DIR -Filter "*.json" -ErrorAction SilentlyContinue

    foreach ($file in $sessionFiles) {
        $data = Get-Content $file.FullName | ConvertFrom-Json
        $pid = $data.pid

        # Check if process is still running
        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($process) {
            $found = $true
            Write-Host ("{0,-20} [pid: {1}] [win: {2}]" -f $data.id, $pid, $data.tmux_window)
            Write-Host "  ├─ Dir:  $($data.cwd)"
            Write-Host "  ├─ Task: $($data.task)"
            Write-Host "  └─ Started: $($data.started)"
            Write-Host ""
        } else {
            # Stale session, remove it
            Remove-Item $file.FullName -Force
        }
    }

    if (-not $found) {
        Write-Host "No active sessions"
    }
}

function claude-cleanup {
    <#
    .SYNOPSIS
    Clean up stale Claude sessions
    #>
    $cleaned = 0
    $sessionFiles = Get-ChildItem -Path $env:CLAUDE_SESSION_DIR -Filter "*.json" -ErrorAction SilentlyContinue

    foreach ($file in $sessionFiles) {
        $data = Get-Content $file.FullName | ConvertFrom-Json
        $process = Get-Process -Id $data.pid -ErrorAction SilentlyContinue

        if (-not $process) {
            $id = $file.BaseName
            Remove-Item $file.FullName -Force
            $msgFile = Join-Path $env:CLAUDE_SESSION_DIR "messages" $id
            if (Test-Path $msgFile) {
                Remove-Item $msgFile -Force
            }
            Write-Host "Removed stale session: $id"
            $cleaned++
        }
    }

    if ($cleaned -eq 0) {
        Write-Host "No stale sessions found"
    } else {
        Write-Host "Cleaned up $cleaned stale session(s)"
    }
}

function claude-kill {
    <#
    .SYNOPSIS
    Kill a specific Claude session
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$SessionId
    )

    $sessionFile = Join-Path $env:CLAUDE_SESSION_DIR "$SessionId.json"
    if (-not (Test-Path $sessionFile)) {
        Write-Host "Session not found: $SessionId" -ForegroundColor Red
        return
    }

    $data = Get-Content $sessionFile | ConvertFrom-Json
    $process = Get-Process -Id $data.pid -ErrorAction SilentlyContinue

    if ($process) {
        Stop-Process -Id $data.pid -Force
        Write-Host "Killed session $SessionId (pid: $($data.pid))"
    }

    Remove-Item $sessionFile -Force
    $msgFile = Join-Path $env:CLAUDE_SESSION_DIR "messages" $SessionId
    if (Test-Path $msgFile) {
        Remove-Item $msgFile -Force
    }
}

function claude-killall {
    <#
    .SYNOPSIS
    Kill all Claude sessions
    #>
    $sessionFiles = Get-ChildItem -Path $env:CLAUDE_SESSION_DIR -Filter "*.json" -ErrorAction SilentlyContinue
    foreach ($file in $sessionFiles) {
        claude-kill $file.BaseName
    }
}

# ============================================================================
# Aliases
# ============================================================================

Set-Alias -Name cld -Value { claude --dangerously-skip-permissions }
Set-Alias -Name gst -Value { git status }
Set-Alias -Name cls -Value claude-ls -Force
