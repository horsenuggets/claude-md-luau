# Claude Workflow Installation Script for Windows PowerShell
# Run with: powershell -ExecutionPolicy Bypass -File install.ps1

param(
    [switch]$Yes,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Colors
function Write-Color {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

# Get script directory
$ScriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Color "Claude Workflow Installation" "Cyan"
Write-Host "=========================================="
Write-Host "Platform: Windows PowerShell"
Write-Host "Source: $ScriptDir"
Write-Host ""

if ($Help) {
    Write-Host "Usage: install.ps1 [-Yes] [-Help]"
    Write-Host "  -Yes    Skip confirmation prompt"
    Write-Host "  -Help   Show this help message"
    exit 0
}

Write-Host "This will install:"
Write-Host "  - PowerShell functions (shipcheck, mkrelease, claude-* commands)"
Write-Host "  - Claude slash commands (/commit, /push, /release, etc.)"
Write-Host "  - Session management utilities"
Write-Host ""

if (-not $Yes) {
    $response = Read-Host "Continue? [y/N]"
    if ($response -notmatch "^[yY]") {
        Write-Host "Aborted."
        exit 1
    }
}

# Check for PowerShell profile
Write-Color "`nChecking PowerShell profile..." "Cyan"
$ProfileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    Write-Color "Created profile directory: $ProfileDir" "Green"
}

# Backup existing profile
if (Test-Path $PROFILE) {
    $backupPath = "$PROFILE.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $PROFILE $backupPath
    Write-Color "Backed up existing profile to: $backupPath" "Yellow"
}

# Add source line to profile
$SourceFile = Join-Path $ScriptDir "shell" "profile.ps1"
$Marker = "# Claude Workflow Configuration"
$SourceLine = ". `"$SourceFile`""

$ProfileContent = ""
if (Test-Path $PROFILE) {
    $ProfileContent = Get-Content $PROFILE -Raw
}

if ($ProfileContent -notmatch [regex]::Escape($Marker)) {
    Add-Content -Path $PROFILE -Value "`n$Marker"
    Add-Content -Path $PROFILE -Value $SourceLine
    Write-Color "Added source line to PowerShell profile" "Green"
} else {
    Write-Color "Skipped profile (already configured)" "Yellow"
}

# Install Claude commands
Write-Color "`nInstalling Claude commands..." "Cyan"
$CommandsDir = Join-Path $env:USERPROFILE ".claude" "commands"
$SourceCommands = Join-Path $ScriptDir "commands"

if (-not (Test-Path $CommandsDir)) {
    New-Item -ItemType Directory -Path $CommandsDir -Force | Out-Null
}

Get-ChildItem -Path $SourceCommands -Filter "*.md" | ForEach-Object {
    $target = Join-Path $CommandsDir $_.Name

    # Remove existing symlink or file
    if (Test-Path $target) {
        Remove-Item $target -Force
    }

    # Create symlink (requires admin on older Windows)
    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $_.FullName -Force | Out-Null
        Write-Color "Linked $($_.Name)" "Green"
    } catch {
        # Fall back to copy if symlink fails
        Copy-Item $_.FullName $target
        Write-Color "Copied $($_.Name) (symlink failed)" "Yellow"
    }
}

# Create session directory
Write-Color "`nCreating session directory..." "Cyan"
$SessionDir = Join-Path $env:USERPROFILE ".claude-sessions" "messages"
if (-not (Test-Path $SessionDir)) {
    New-Item -ItemType Directory -Path $SessionDir -Force | Out-Null
}
Write-Color "Created session directory" "Green"

# Configure startup hook
Write-Color "`nConfiguring startup hook..." "Cyan"
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$SettingsFile = Join-Path $ClaudeDir "settings.json"

if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
}

if (Test-Path $SettingsFile) {
    $content = Get-Content $SettingsFile -Raw
    if ($content -match "claude-md-luau") {
        Write-Color "Skipped startup hook (already configured)" "Yellow"
    } else {
        # Backup existing settings
        $backupPath = "$SettingsFile.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item $SettingsFile $backupPath
        Write-Color "Backed up existing settings to: $backupPath" "Yellow"

        try {
            $settings = $content | ConvertFrom-Json
            if (-not $settings.hooks) {
                $settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue @{}
            }
            $settings.hooks.SessionStart = @(
                @{
                    hooks = @(
                        @{
                            type = "command"
                            command = "Get-Content `$env:USERPROFILE/git/claude-md-luau/CLAUDE.md"
                        }
                    )
                }
            )
            $settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile
            Write-Color "Added startup hook to existing settings" "Green"
        } catch {
            Write-Color "Warning: Could not merge settings automatically" "Yellow"
            Write-Host "Please manually add the startup hook from config/settings.json.example"
        }
    }
} else {
    # Create new settings file
    $ExampleFile = Join-Path $ScriptDir "config" "settings.json.example"
    if (Test-Path $ExampleFile) {
        # Modify the command for Windows
        $content = Get-Content $ExampleFile -Raw
        $content = $content -replace 'cat ~/git', 'Get-Content $env:USERPROFILE/git'
        $content | Set-Content $SettingsFile
        Write-Color "Created settings.json with startup hook" "Green"
    } else {
        Write-Color "Warning: Example settings file not found" "Yellow"
    }
}

# Check dependencies
Write-Color "`nChecking dependencies..." "Cyan"
$missing = @()

# Check for gh CLI
if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
    Write-Color "Note: gh CLI not found (needed for PR commands)" "Yellow"
}

# Check for git
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    $missing += "git"
}

# Check for Claude CLI
if (-not (Get-Command "claude" -ErrorAction SilentlyContinue)) {
    Write-Color "Note: Claude CLI not found" "Yellow"
}

if ($missing.Count -gt 0) {
    Write-Color "Missing required dependencies: $($missing -join ', ')" "Yellow"
    Write-Host ""
    Write-Host "Install with:"
    Write-Host "  winget install $($missing -join ' ')"
} else {
    Write-Color "All required dependencies installed" "Green"
}

Write-Host ""
Write-Color "Installation complete!" "Green"
Write-Host ""
Write-Host "To activate the new configuration, run:"
Write-Host "  . `$PROFILE"
Write-Host ""
Write-Host "Or start a new PowerShell session."
Write-Host ""
Write-Host "Available commands:"
Write-Host "  Functions: shipcheck, mkrelease, ghprc, genpass"
Write-Host "  Claude sessions: claude-ls, claude-cleanup, claude-kill"
Write-Host "  Slash commands: /commit, /push, /release, /ship, /check, /all"
