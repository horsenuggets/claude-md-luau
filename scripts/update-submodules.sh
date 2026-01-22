#!/bin/bash
# Update claude-md-luau submodules across all repos in ~/git
# Works on macOS, Linux, and WSL

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
GIT_DIR="${GIT_DIR:-$HOME/git}"
SUBMODULE_PATH="${SUBMODULE_PATH:-Submodules/claude-md-luau}"

echo -e "${BLUE}Update claude-md-luau Submodules${NC}"
echo "=========================================="
echo "Scanning: $GIT_DIR"
echo "Submodule path: $SUBMODULE_PATH"
echo ""

# Parse arguments
COMMIT_CHANGES=false
PUSH_CHANGES=false
DRY_RUN=false

print_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -c, --commit    Commit submodule updates"
    echo "  -p, --push      Commit and push submodule updates"
    echo "  -d, --dry-run   Show what would be updated without making changes"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  GIT_DIR         Directory containing git repos (default: ~/git)"
    echo "  SUBMODULE_PATH  Path to submodule within repos (default: Submodules/claude-md-luau)"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--commit) COMMIT_CHANGES=true; shift ;;
        -p|--push) COMMIT_CHANGES=true; PUSH_CHANGES=true; shift ;;
        -d|--dry-run) DRY_RUN=true; shift ;;
        -h|--help) print_help; exit 0 ;;
        *) echo "Unknown option: $1"; print_help; exit 1 ;;
    esac
done

# Track results
updated_repos=()
skipped_repos=()
failed_repos=()

# Find repos with the submodule
find_repos_with_submodule() {
    local repos=()

    for repo_dir in "$GIT_DIR"/*/; do
        [[ -d "$repo_dir" ]] || continue
        [[ -d "$repo_dir/.git" ]] || continue

        # Skip if this is claude-md-luau itself
        [[ "$(basename "$repo_dir")" == "claude-md-luau" ]] && continue

        # Check if .gitmodules exists and contains our submodule
        local gitmodules="$repo_dir/.gitmodules"
        if [[ -f "$gitmodules" ]] && grep -q "claude-md-luau" "$gitmodules" 2>/dev/null; then
            repos+=("$repo_dir")
        fi
    done

    echo "${repos[@]}"
}

# Update submodule in a repo
update_repo_submodule() {
    local repo_dir="$1"
    local repo_name=$(basename "$repo_dir")

    echo -e "  ${BLUE}Processing:${NC} $repo_name"

    cd "$repo_dir"

    # Check if submodule directory exists
    if [[ ! -d "$SUBMODULE_PATH" ]]; then
        echo -e "    ${YELLOW}Submodule directory not found, initializing...${NC}"
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "    ${YELLOW}[DRY RUN] Would initialize submodule${NC}"
            skipped_repos+=("$repo_name (dry run)")
            return 0
        fi
        git submodule update --init "$SUBMODULE_PATH" 2>/dev/null || {
            echo -e "    ${RED}Failed to initialize submodule${NC}"
            failed_repos+=("$repo_name (init failed)")
            return 1
        }
    fi

    # Get current commit
    local old_commit=$(git -C "$SUBMODULE_PATH" rev-parse HEAD 2>/dev/null || echo "none")

    # Update submodule
    if [[ "$DRY_RUN" == "true" ]]; then
        # Fetch to see what would change
        git -C "$SUBMODULE_PATH" fetch origin main 2>/dev/null || true
        local new_commit=$(git -C "$SUBMODULE_PATH" rev-parse origin/main 2>/dev/null || echo "none")

        if [[ "$old_commit" != "$new_commit" ]]; then
            echo -e "    ${YELLOW}[DRY RUN] Would update from ${old_commit:0:7} to ${new_commit:0:7}${NC}"
            updated_repos+=("$repo_name (dry run)")
        else
            echo -e "    ${GREEN}Already up to date${NC}"
            skipped_repos+=("$repo_name (up to date)")
        fi
        return 0
    fi

    # Actually update
    git submodule update --remote --merge "$SUBMODULE_PATH" 2>/dev/null || {
        echo -e "    ${RED}Failed to update submodule${NC}"
        failed_repos+=("$repo_name (update failed)")
        return 1
    }

    # Get new commit
    local new_commit=$(git -C "$SUBMODULE_PATH" rev-parse HEAD 2>/dev/null || echo "none")

    if [[ "$old_commit" != "$new_commit" ]]; then
        echo -e "    ${GREEN}Updated from ${old_commit:0:7} to ${new_commit:0:7}${NC}"
        updated_repos+=("$repo_name")

        # Commit if requested
        if [[ "$COMMIT_CHANGES" == "true" ]]; then
            git add "$SUBMODULE_PATH"
            git commit -m "Update claude-md-luau submodule" 2>/dev/null || {
                echo -e "    ${YELLOW}Nothing to commit (already staged elsewhere?)${NC}"
            }

            if [[ "$PUSH_CHANGES" == "true" ]]; then
                echo -e "    ${BLUE}Pushing...${NC}"
                git push 2>/dev/null || {
                    echo -e "    ${YELLOW}Push failed (may need PR)${NC}"
                }
            fi
        fi
    else
        echo -e "    ${GREEN}Already up to date${NC}"
        skipped_repos+=("$repo_name (up to date)")
    fi
}

# Main
main() {
    local repos=($(find_repos_with_submodule))

    if [[ ${#repos[@]} -eq 0 ]]; then
        echo "No repos found with claude-md-luau submodule"
        exit 0
    fi

    echo "Found ${#repos[@]} repo(s) with submodule"
    echo ""

    for repo in "${repos[@]}"; do
        update_repo_submodule "$repo"
    done

    # Summary
    echo ""
    echo -e "${BLUE}Summary${NC}"
    echo "=========================================="

    if [[ ${#updated_repos[@]} -gt 0 ]]; then
        echo -e "${GREEN}Updated (${#updated_repos[@]}):${NC}"
        for repo in "${updated_repos[@]}"; do
            echo "  - $repo"
        done
    fi

    if [[ ${#skipped_repos[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Skipped (${#skipped_repos[@]}):${NC}"
        for repo in "${skipped_repos[@]}"; do
            echo "  - $repo"
        done
    fi

    if [[ ${#failed_repos[@]} -gt 0 ]]; then
        echo -e "${RED}Failed (${#failed_repos[@]}):${NC}"
        for repo in "${failed_repos[@]}"; do
            echo "  - $repo"
        done
    fi

    echo ""
    echo -e "${GREEN}Done!${NC}"
}

main
