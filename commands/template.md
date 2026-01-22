---
description: Manage the luau-package-template and sync changes to repos
---

Manage the luau-package-template repository.

## Subcommands

### update

Update `~/git/luau-package-template` to use the latest versions of all forked tools and dependencies.

1. Check GitHub releases for latest versions of:
   - `horsenuggets/lune` (rokit.toml)
   - `horsenuggets/wally` (rokit.toml)
   - `horsenuggets/t` (wally.toml)
   - `horsenuggets/testable` (wally.toml)

2. Update rokit.toml and wally.toml with the latest versions

3. Commit the changes if any updates were made

### sync

Update the current repository's layout and environment to match EXACTLY how it appears in
`~/git/luau-package-template`. The goal is that all configuration files, workflows, and
project structure should be identical to the template - only the actual source code (the
package implementation) should differ.

1. Generate git-style diffs between the template and current repo for these files/directories:
   - `.editorconfig`
   - `.gitattributes`
   - `.gitignore`
   - `.luaurc`
   - `rokit.toml`
   - `stylua.toml`
   - `wally.toml` (only [dev-dependencies] section)
   - `.github/workflows/*` (all workflow files)
   - Any other config files present in the template but missing in current repo

2. Show the user the exact diffs so they can see precisely what will change

3. Apply all changes to make the current repo match the template exactly (use `git diff` and
   patch-style application when helpful to ensure exact matching)

4. For `wally.toml`, preserve the current repo's [package] section and [dependencies] - only
   sync the [dev-dependencies] section from the template

5. Commit the changes with a clear message describing the template sync

## Arguments

- `$ARGUMENTS` - The subcommand to run (update or sync)

## Usage

- `/template update` - Update template to latest forked tool versions
- `/template sync` - Sync template changes to current repo
