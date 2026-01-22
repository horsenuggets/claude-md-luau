---
description: Analyze uncommitted changes and break them into logical commits
---

Analyze all uncommitted changes in the current repository and create logical, well-organized commits.

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

4. Commit message formatting:
   - Use sentence case (start with a capital letter)
   - Do NOT use conventional commit prefixes like `test:`, `chore:`, `feat:`, `fix:`, etc.

5. Be optimistic about committing. Almost everything should be committed. Only skip files if they are clearly not meant to be in the repo, such as:
   - Files containing hardcoded secrets or credentials (e.g., `.env` with real API keys)
   - Large binary files that were accidentally created
   - Personal IDE settings that aren't already gitignored
   - Build artifacts that should be gitignored

6. If you do skip any files (which should be extremely rare), let me know what was skipped and why.

7. Do NOT push to remote - just create the local commits.
