#!/bin/bash
# Claude Workflow Sync Script
# Syncs the claude-md-luau repository and updates all installations
# Works on macOS, Linux, and WSL

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}Claude Workflow Sync${NC}"
echo "=========================================="
echo "Repository: $SCRIPT_DIR"
echo ""

# Parse arguments
USE_CLAUDE=false
PUSH_CHANGES=false
PULL_ONLY=false
UPDATE_SUBMODULES=false

print_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -p, --pull        Pull changes only (default behavior)"
    echo "  -P, --push        Push local changes after pulling"
    echo "  -c, --claude      Use Claude to help resolve merge conflicts"
    echo "  -s, --submodules  Update submodules in ~/git projects"
    echo "  -a, --all         Run full sync (pull, push, submodules)"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Pull latest changes"
    echo "  $0 -P                 # Pull and push"
    echo "  $0 -c -P              # Pull, resolve conflicts with Claude, push"
    echo "  $0 -a                 # Full sync including submodules"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--pull) PULL_ONLY=true; shift ;;
        -P|--push) PUSH_CHANGES=true; shift ;;
        -c|--claude) USE_CLAUDE=true; shift ;;
        -s|--submodules) UPDATE_SUBMODULES=true; shift ;;
        -a|--all)
            PUSH_CHANGES=true
            UPDATE_SUBMODULES=true
            shift
            ;;
        -h|--help) print_help; exit 0 ;;
        *) echo "Unknown option: $1"; print_help; exit 1 ;;
    esac
done

# Change to repo directory
cd "$SCRIPT_DIR"

# Check for uncommitted changes
check_local_changes() {
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        return 0  # Has changes
    fi
    if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
        return 0  # Has untracked files
    fi
    return 1  # No changes
}

# Stash changes if needed
stash_if_needed() {
    if check_local_changes; then
        echo -e "${YELLOW}Stashing local changes...${NC}"
        git stash push -m "sync-script-$(date +%Y%m%d%H%M%S)"
        return 0
    fi
    return 1
}

# Unstash changes
unstash_if_needed() {
    local stash_list=$(git stash list | head -1)
    if [[ "$stash_list" == *"sync-script-"* ]]; then
        echo -e "${YELLOW}Restoring stashed changes...${NC}"
        git stash pop
    fi
}

# Pull changes
pull_changes() {
    echo -e "${BLUE}Pulling latest changes...${NC}"

    # Fetch first
    git fetch origin

    # Check if we're behind
    local behind=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo "0")
    local ahead=$(git rev-list origin/main..HEAD --count 2>/dev/null || echo "0")

    if [[ "$behind" -eq 0 ]]; then
        echo -e "${GREEN}Already up to date${NC}"
        return 0
    fi

    echo "  Behind by $behind commit(s), ahead by $ahead commit(s)"

    # Try to pull
    if ! git pull --rebase origin main 2>/dev/null; then
        echo -e "${YELLOW}Merge conflict detected${NC}"

        if [[ "$USE_CLAUDE" == "true" ]]; then
            resolve_with_claude
        else
            echo -e "${RED}Please resolve conflicts manually or use -c flag to use Claude${NC}"
            echo ""
            echo "Conflicted files:"
            git diff --name-only --diff-filter=U
            return 1
        fi
    fi

    echo -e "${GREEN}Pull successful${NC}"
}

# Resolve conflicts with Claude
resolve_with_claude() {
    echo -e "${BLUE}Invoking Claude to resolve conflicts...${NC}"

    # Check if claude is available
    if ! command -v claude &> /dev/null; then
        echo -e "${RED}Claude CLI not found. Please resolve conflicts manually.${NC}"
        return 1
    fi

    # Get conflicted files
    local conflicts=$(git diff --name-only --diff-filter=U)

    if [[ -z "$conflicts" ]]; then
        echo -e "${GREEN}No conflicts to resolve${NC}"
        return 0
    fi

    # Create a prompt for Claude
    local prompt="Please resolve the merge conflicts in these files. For each conflict, analyze both versions and choose the most appropriate resolution. After resolving, stage the files with git add.

Conflicted files:
$conflicts

Current git status:
$(git status)

For each file, show me the conflict markers and explain your resolution choice."

    # Run Claude
    echo "$prompt" | claude --print

    # Check if conflicts are resolved
    if git diff --name-only --diff-filter=U | grep -q .; then
        echo -e "${RED}Some conflicts remain unresolved${NC}"
        return 1
    fi

    # Continue the rebase
    git rebase --continue

    echo -e "${GREEN}Conflicts resolved with Claude's help${NC}"
}

# Push changes
push_changes() {
    echo -e "${BLUE}Pushing changes...${NC}"

    # Check if there are commits to push
    local ahead=$(git rev-list origin/main..HEAD --count 2>/dev/null || echo "0")

    if [[ "$ahead" -eq 0 ]]; then
        echo -e "${GREEN}Nothing to push${NC}"
        return 0
    fi

    echo "  Pushing $ahead commit(s)..."

    if git push origin main; then
        echo -e "${GREEN}Push successful${NC}"
    else
        echo -e "${RED}Push failed${NC}"
        return 1
    fi
}

# Copy files to system locations
copy_to_system() {
    echo -e "${BLUE}Updating system files...${NC}"

    # The install script uses symlinks, so files are automatically updated
    # We just need to verify the symlinks are intact

    local commands_dir="$HOME/.claude/commands"
    local source_commands="$SCRIPT_DIR/commands"

    # Check if symlinks are working
    for cmd_file in "$source_commands"/*.md; do
        local filename=$(basename "$cmd_file")
        local target="$commands_dir/$filename"

        if [[ -L "$target" ]]; then
            # Symlink exists, verify it points to the right place
            local link_target=$(readlink "$target")
            if [[ "$link_target" != "$cmd_file" ]]; then
                rm "$target"
                ln -sf "$cmd_file" "$target"
                echo -e "${YELLOW}Fixed symlink:${NC} $filename"
            fi
        elif [[ ! -e "$target" ]]; then
            ln -sf "$cmd_file" "$target"
            echo -e "${GREEN}Created symlink:${NC} $filename"
        fi
    done

    echo -e "${GREEN}System files updated${NC}"
}

# Update submodules in ~/git projects
update_submodules() {
    echo -e "${BLUE}Updating submodules in ~/git projects...${NC}"

    # Run the dedicated submodule update script
    local submodule_script="$SCRIPT_DIR/scripts/update-submodules.sh"

    if [[ -x "$submodule_script" ]]; then
        "$submodule_script"
    else
        # Inline implementation if script doesn't exist yet
        local git_dir="$HOME/git"
        local count=0

        # Find all repos with claude-md-luau submodule
        for repo in "$git_dir"/*/; do
            [[ -d "$repo" ]] || continue
            [[ -d "$repo/.git" ]] || continue

            # Check if this repo has claude-md-luau as a submodule
            if [[ -f "$repo/.gitmodules" ]] && grep -q "claude-md-luau" "$repo/.gitmodules" 2>/dev/null; then
                echo "  Updating submodule in: $(basename "$repo")"
                (
                    cd "$repo"
                    git submodule update --remote --merge Submodules/claude-md-luau 2>/dev/null || true
                )
                ((count++))
            fi
        done

        if [[ $count -eq 0 ]]; then
            echo "  No repos with claude-md-luau submodule found"
        else
            echo -e "${GREEN}Updated $count repo(s)${NC}"
        fi
    fi
}

# Main sync function
main() {
    local stashed=false

    # Stash any local changes
    if stash_if_needed; then
        stashed=true
    fi

    # Pull changes
    if ! pull_changes; then
        if [[ "$stashed" == "true" ]]; then
            unstash_if_needed
        fi
        exit 1
    fi

    # Push changes if requested
    if [[ "$PUSH_CHANGES" == "true" ]]; then
        if [[ "$stashed" == "true" ]]; then
            unstash_if_needed
            stashed=false
        fi
        push_changes
    fi

    # Restore stashed changes
    if [[ "$stashed" == "true" ]]; then
        unstash_if_needed
    fi

    # Copy to system
    copy_to_system

    # Update submodules if requested
    if [[ "$UPDATE_SUBMODULES" == "true" ]]; then
        update_submodules
    fi

    echo ""
    echo -e "${GREEN}Sync complete!${NC}"
}

main
