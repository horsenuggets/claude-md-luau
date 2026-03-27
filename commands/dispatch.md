---
description: Generate a prompt for another session to change, release, and bump a dependency
---

Generate a clipboard-ready prompt for a new Claude Code session that will:

1. Navigate to the specified repository
2. Make the described change
3. Commit and push (`/push`)
4. Release a patch version (`/release patch`)
5. Bump the dependency across all repos (`/all /bump <package>`)

## Arguments

The first argument is the package/repo name (e.g., `commandline-luau`, `chalk-luau`).
Everything after is the change description.

Example: `/dispatch commandline-luau sort flags alphabetically in help output`

## Instructions

1. Find the repo by searching ~/git recursively for a directory matching the package name
2. Read the repo's current VERSION file and wally.toml to get the package name
3. Build a prompt like this:

```
/upstream <package-name> <change description>
```

4. Copy the prompt to the clipboard using `pbcopy`
5. Tell the user it's on their clipboard and ready to paste into a new session

Keep the prompt minimal — just the repo path, what to change, and the release/bump steps.
Do NOT include project context, architecture details, or conversation history.

$ARGUMENTS
