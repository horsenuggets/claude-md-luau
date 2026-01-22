---
description: Create a worktree to work in parallel with another Claude instance
---

Another Claude instance is currently working in this repository. Create a git worktree in `~/git/worktrees` so you can work on this repo in parallel without conflicts.

Steps:
1. Get the current repo name from the current directory
2. Create a worktree at `~/git/worktrees/<repo-name>-<branch-name>` (use a descriptive branch name for the work you're about to do)
3. Change your working directory to the new worktree
4. Confirm the new working directory and branch to the user

Use `git worktree add <path> -b <new-branch-name>` to create the worktree with a new branch.
