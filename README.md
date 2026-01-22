# claude-md-luau

Claude Code guidelines and workflow automation for Luau projects.

## Overview

This repository provides:

- **Guidelines** - Comprehensive coding standards for Luau development with Claude Code
- **Shell Functions** - Cross-platform utilities for git workflows and Claude session management
- **Slash Commands** - Custom Claude commands for commits, releases, and multi-repo operations
- **Sync Scripts** - Tools to keep your workflow in sync across machines

## Quick Start

### macOS / Linux / WSL

```bash
# Clone the repository
git clone https://github.com/horsenuggets/claude-md-luau.git ~/git/claude-md-luau

# Run the installer
~/git/claude-md-luau/scripts/install.sh
```

### Windows (PowerShell)

```powershell
# Clone the repository
git clone https://github.com/horsenuggets/claude-md-luau.git $env:USERPROFILE\git\claude-md-luau

# Run the installer (may need admin for symlinks)
& $env:USERPROFILE\git\claude-md-luau\scripts\install.ps1
```

### Windows (Command Prompt)

```cmd
git clone https://github.com/horsenuggets/claude-md-luau.git %USERPROFILE%\git\claude-md-luau
%USERPROFILE%\git\claude-md-luau\scripts\install.bat
```

## What Gets Installed

The installer configures:

1. **Shell Configuration** - Sources `shell/zshrc` from your shell rc file
2. **Claude Commands** - Symlinks commands to `~/.claude/commands/`
3. **Startup Hook** - Loads CLAUDE.md guidelines when Claude starts
4. **Session Directory** - Creates `~/.claude-sessions/` for session management

## Available Shell Functions

### Git Utilities

| Function | Description |
|----------|-------------|
| `shipcheck` | Check if repo has uncommitted changes, unpushed commits, or unreleased changes |
| `ghprc` | `gh pr create` wrapper that targets origin remote and adds @me as assignee |
| `genpass [len]` | Generate random password (default 20 chars) and copy to clipboard |
| `mkrelease <ver>` | Create release branch that merges release history while keeping main's content |

### Claude Session Management

| Function | Alias | Description |
|----------|-------|-------------|
| `claude-ls` | `cls` | List active Claude sessions |
| `claude-spawn <dir> [task]` | `csp` | Spawn Claude in new tmux window |
| `claude-repo <name> [task]` | `crepo` | Spawn Claude in a repo from ~/git |
| `claude-send <id> <msg>` | | Send message to another Claude session |
| `claude-broadcast <msg>` | | Send message to all Claude sessions |
| `claude-inbox` | | Read messages for current session |
| `claude-cleanup` | | Remove stale sessions |
| `claude-kill <id>` | | Kill a specific Claude session |
| `claude-killall` | | Kill all Claude sessions |
| `claude-start` | | Start or attach to tmux claude session |

## Available Slash Commands

| Command | Description |
|---------|-------------|
| `/commit` | Analyze changes and create logical commits |
| `/push` | Commit and push to remote |
| `/release [type]` | Full release workflow (patch/minor/major) |
| `/ship` | Shortcut for `/push` + `/release patch` |
| `/all <change>` | Apply change across all repos in ~/git |
| `/check` | Verify compliance with CLAUDE.md guidelines |
| `/repo <name>` | Work in a specific repository |
| `/parallel` | Create worktree for parallel work |
| `/remember <note>` | Add note to CLAUDE.md |
| `/template [cmd]` | Manage luau-package-template |

## Syncing Updates

Keep your workflow configuration up to date:

```bash
# Pull latest changes
~/git/claude-md-luau/scripts/sync.sh

# Pull and push local changes
~/git/claude-md-luau/scripts/sync.sh -P

# Full sync with submodule updates
~/git/claude-md-luau/scripts/sync.sh -a
```

## Using as a Submodule

Add to your project:

```bash
git submodule add https://github.com/horsenuggets/claude-md-luau.git Submodules/claude-md-luau
```

Update all submodules across your repos:

```bash
~/git/claude-md-luau/scripts/update-submodules.sh
```

## Platform Support

| Platform | Shell Config | Commands | Session Mgmt |
|----------|-------------|----------|--------------|
| macOS | zsh/bash | Yes | Yes (tmux) |
| Linux | zsh/bash | Yes | Yes (tmux) |
| WSL | zsh/bash | Yes | Yes (tmux) |
| Git Bash | bash | Yes | Limited |
| PowerShell | profile.ps1 | Yes | Partial |

## License

MIT
