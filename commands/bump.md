---
description: Bump a dependency to its latest version in rokit.toml or wally.toml
---

Bump a dependency to its latest released version.

## Instructions

1. Determine which dependency to bump from the arguments or context:
   - If arguments specify a tool name (e.g., `rojo`, `lune`, `wally`), bump that tool
   - If no arguments are given, infer from context — if you just released a new version of a
     tool in this session, bump that tool
   - If still ambiguous, ask the user

2. Find the latest released version:
   - For rokit tools (in `rokit.toml`): check GitHub releases with
     `gh release list --repo <owner>/<repo> --limit 1`
   - For wally packages (in `wally.toml`): check the current version reference and the
     latest available

3. Update the version in the current repo's `rokit.toml` or `wally.toml`:
   - Only update the specific dependency, not others
   - Preserve the file format exactly

4. After updating, run `rokit install` to install the new version locally.

5. If the tool was updated, verify the new version with `<tool> --version`.

6. Do NOT commit unless the user explicitly includes `/commit` or `/push` in their request.

## When used with /all

When invoked as `/all /bump <tool>`, this bumps the specified dependency across all repos in
~/git. In this mode:

1. Find all `rokit.toml` and/or `wally.toml` files that reference the old version
2. Update them all to the latest version
3. Commit each change in its respective repo
4. Report a summary of which repos were updated

## Arguments

- `$ARGUMENTS` - Optional: the dependency name to bump (e.g., `rojo`, `lune`, `wally`). If
  omitted, inferred from context.
