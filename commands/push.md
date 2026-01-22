---
description: Analyze uncommitted changes, break them into logical commits, and push
---

Analyze all uncommitted changes in the current repository, create logical commits, and push to remote.

## Instructions

1. First, run `git status` to see all staged and unstaged changes, and `git diff` to understand what changed.

2. Analyze the changes and group them into logical commits. Consider:
   - Changes to the same feature or component
   - Related refactoring
   - Documentation updates
   - Test additions/modifications
   - Dependency updates
   - Bug fixes vs new features

3. For each logical group, create a separate commit with a clear, descriptive message that explains the "why" not just the "what".

4. Be optimistic about committing. Almost everything should be committed. Only skip files if they are clearly not meant to be in the repo, such as:
   - Files containing hardcoded secrets or credentials (e.g., `.env` with real API keys)
   - Large binary files that were accidentally created
   - Personal IDE settings that aren't already gitignored
   - Build artifacts that should be gitignored

5. If you do skip any files (which should be extremely rare), let me know what was skipped and why.

6. Follow the repository's existing commit message style if one is apparent from `git log`.

7. After all commits are created, push to the remote repository using `git push`. If the branch has no upstream, use `git push -u origin <branch-name>`.

8. If the push fails due to branch protection (error contains "protected branch" or "Changes must be made through a pull request"):
   - Reset the commit(s) with `git reset --soft HEAD~N` where N is the number of commits just created
   - Create a feature branch with an appropriate name based on the changes (e.g., `bugfix/fix-something`, `feature/add-something`)
   - Re-commit the changes on the new branch
   - Push the feature branch with `git push -u origin <branch-name>`
   - Create a PR to the original branch using `gh prc` with a clear title and summary
   - Report the PR URL to the user
