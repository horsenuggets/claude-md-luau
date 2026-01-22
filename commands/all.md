---
description: Apply a change across all local git repos in ~/git and commit
---

Apply the requested change across all git repositories in ~/git and commit each change.

## Instructions

1. First, find all git repositories in ~/git by searching for directories containing a `.git` folder. Exclude:
   - Directories inside `node_modules`, `Packages`, `DevPackages`, `Submodules`, `_Index`, `modules`
   - Repositories in `~/git/archive`
   - Worktree directories if the main repo is also present (prefer the non-worktree location)

2. For each repository found, apply the requested change. The change might be:
   - Editing a specific file (e.g., `.editorconfig`, `CLAUDE.md`)
   - Adding a new file
   - Running a transformation across files
   - Any other modification the user specifies

3. After making the change in each repo:
   - Stage the relevant files with `git add`
   - Commit with a clear, descriptive message
   - Make sure commits are on the `main` branch (checkout main first if needed)

4. Do NOT push unless the user explicitly includes `/push` in their request.

5. Report a summary at the end showing:
   - Which repos were modified
   - The branch and commit hash for each
   - Any repos that were skipped and why

## Arguments

- `$ARGUMENTS` - The change to apply across all repos

## Example Usage

- `/all add yml/yaml 2-space indent rule to .editorconfig`
- `/all update the README title format`
- `/all /push add CI workflow for linting` (this would also push after committing)
