#!/bin/bash
# Claude Workflow Installation Script
# Works on macOS, Linux, and WSL

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*) echo "gitbash" ;;
        *) echo "unknown" ;;
    esac
}

# Get script directory (where claude-md-luau is cloned)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLATFORM=$(detect_platform)

echo -e "${BLUE}Claude Workflow Installation${NC}"
echo "=========================================="
echo "Platform: $PLATFORM"
echo "Source: $SCRIPT_DIR"
echo ""

# Detect shell
if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    SHELL_RC="$HOME/.profile"
    SHELL_NAME="sh"
fi

echo "Detected shell: $SHELL_NAME ($SHELL_RC)"
echo ""

# Function to backup a file
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d%H%M%S)"
        cp "$file" "$backup"
        echo -e "${YELLOW}Backed up${NC} $file to $backup"
    fi
}

# Function to add source line to rc file
add_source_line() {
    local rc_file="$1"
    local source_file="$2"
    local marker="$3"

    if ! grep -q "$marker" "$rc_file" 2>/dev/null; then
        backup_file "$rc_file"
        echo "" >> "$rc_file"
        echo "# $marker" >> "$rc_file"
        echo "source \"$source_file\"" >> "$rc_file"
        echo -e "${GREEN}Added${NC} source line to $rc_file"
    else
        echo -e "${YELLOW}Skipped${NC} $rc_file (already configured)"
    fi
}

# Install shell configuration
install_shell_config() {
    echo -e "${BLUE}Installing shell configuration...${NC}"

    local zshrc_source="$SCRIPT_DIR/shell/zshrc"

    if [[ -f "$zshrc_source" ]]; then
        add_source_line "$SHELL_RC" "$zshrc_source" "Claude Workflow Configuration"
    else
        echo -e "${RED}Error:${NC} Shell config not found at $zshrc_source"
        return 1
    fi

    # Also add aliases if using bash
    local aliases_source="$SCRIPT_DIR/shell/aliases"
    if [[ -f "$aliases_source" ]]; then
        # Check if aliases file exists and source it
        if [[ ! -f "$HOME/.aliases" ]]; then
            ln -sf "$aliases_source" "$HOME/.aliases"
            echo -e "${GREEN}Linked${NC} $HOME/.aliases"
        fi

        # Add source line for aliases
        if ! grep -q "source.*\.aliases" "$SHELL_RC" 2>/dev/null; then
            echo "" >> "$SHELL_RC"
            echo "# Load aliases" >> "$SHELL_RC"
            echo '[[ -f ~/.aliases ]] && source ~/.aliases' >> "$SHELL_RC"
            echo -e "${GREEN}Added${NC} aliases source line to $SHELL_RC"
        fi
    fi
}

# Install Claude commands
install_claude_commands() {
    echo ""
    echo -e "${BLUE}Installing Claude commands...${NC}"

    local commands_dir="$HOME/.claude/commands"
    local source_commands="$SCRIPT_DIR/commands"

    # Create commands directory if it doesn't exist
    mkdir -p "$commands_dir"

    # Copy or symlink command files
    for cmd_file in "$source_commands"/*.md; do
        if [[ -f "$cmd_file" ]]; then
            local filename=$(basename "$cmd_file")
            local target="$commands_dir/$filename"

            # Use symlink for easy updates
            if [[ -L "$target" ]]; then
                rm "$target"
            fi

            ln -sf "$cmd_file" "$target"
            echo -e "${GREEN}Linked${NC} $filename"
        fi
    done
}

# Create session directory
create_session_dir() {
    echo ""
    echo -e "${BLUE}Creating session directory...${NC}"

    mkdir -p "$HOME/.claude-sessions/messages"
    echo -e "${GREEN}Created${NC} $HOME/.claude-sessions/"
}

# Configure startup hook
configure_startup_hook() {
    echo ""
    echo -e "${BLUE}Configuring startup hook...${NC}"

    local settings_file="$HOME/.claude/settings.json"
    local settings_dir="$HOME/.claude"

    # Create .claude directory if needed
    mkdir -p "$settings_dir"

    # Check if settings.json exists
    if [[ -f "$settings_file" ]]; then
        # Check if hook is already configured
        if grep -q "claude-md-luau/CLAUDE.md" "$settings_file" 2>/dev/null; then
            echo -e "${YELLOW}Skipped${NC} startup hook (already configured)"
            return 0
        fi

        # Backup existing settings
        backup_file "$settings_file"

        # Try to merge the hook configuration using jq
        if command -v jq &> /dev/null; then
            local hook_config='{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"cat ~/git/claude-md-luau/CLAUDE.md"}]}]}}'
            local merged=$(jq -s '.[0] * .[1]' "$settings_file" <(echo "$hook_config"))
            echo "$merged" > "$settings_file"
            echo -e "${GREEN}Added${NC} startup hook to existing settings"
        else
            echo -e "${YELLOW}Warning:${NC} jq not installed, cannot merge settings automatically"
            echo "Please manually add the startup hook from config/settings.json.example"
            return 0
        fi
    else
        # Create new settings file from example
        local example_file="$SCRIPT_DIR/config/settings.json.example"
        if [[ -f "$example_file" ]]; then
            cp "$example_file" "$settings_file"
            echo -e "${GREEN}Created${NC} $settings_file with startup hook"
        else
            echo -e "${YELLOW}Warning:${NC} Example settings file not found"
            return 0
        fi
    fi
}

# Install dependencies check
check_dependencies() {
    echo ""
    echo -e "${BLUE}Checking dependencies...${NC}"

    local missing=()

    # Check for jq (required for session management)
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi

    # Check for tmux (optional but recommended)
    if ! command -v tmux &> /dev/null; then
        echo -e "${YELLOW}Note:${NC} tmux not found (optional, needed for claude-spawn)"
    fi

    # Check for gh CLI
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}Note:${NC} gh CLI not found (needed for PR commands)"
    fi

    # Check for Claude CLI
    if ! command -v claude &> /dev/null; then
        echo -e "${YELLOW}Note:${NC} Claude CLI not found"
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Missing required dependencies:${NC} ${missing[*]}"
        echo ""
        echo "Install with:"
        case "$PLATFORM" in
            macos)
                echo "  brew install ${missing[*]}"
                ;;
            linux|wsl)
                echo "  sudo apt install ${missing[*]}"
                echo "  # or"
                echo "  sudo dnf install ${missing[*]}"
                ;;
        esac
        return 1
    else
        echo -e "${GREEN}All required dependencies installed${NC}"
    fi
}

# Main installation
main() {
    echo "This will install:"
    echo "  - Shell functions (shipcheck, mkrelease, claude-* commands)"
    echo "  - Claude slash commands (/commit, /push, /release, etc.)"
    echo "  - Session management utilities"
    echo ""

    # Parse arguments
    local skip_confirm=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y|--yes) skip_confirm=true; shift ;;
            -h|--help)
                echo "Usage: $0 [-y|--yes] [-h|--help]"
                echo "  -y, --yes    Skip confirmation prompt"
                echo "  -h, --help   Show this help message"
                exit 0
                ;;
            *) shift ;;
        esac
    done

    if [[ "$skip_confirm" != "true" ]]; then
        read -p "Continue? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    fi

    echo ""
    check_dependencies || true
    install_shell_config
    install_claude_commands
    create_session_dir
    configure_startup_hook

    echo ""
    echo -e "${GREEN}Installation complete!${NC}"
    echo ""
    echo "To activate the new configuration, run:"
    echo "  source $SHELL_RC"
    echo ""
    echo "Or start a new terminal session."
    echo ""
    echo "Available commands:"
    echo "  Shell: shipcheck, mkrelease, ghprc, genpass"
    echo "  Claude sessions: claude-ls, claude-spawn, claude-repo, claude-kill"
    echo "  Slash commands: /commit, /push, /release, /ship, /check, /all"
}

main "$@"
