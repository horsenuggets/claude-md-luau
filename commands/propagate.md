---
description: Release a patch version and bump the dependency across all repos
---

Release the current repo as a patch version, then bump it across all downstream repos.
This is a shortcut for `/ship` followed by `/all /bump <package>`.

## Instructions

### Phase 1: Release

1. Run `/ship` to commit, push, and release a patch version. Follow all of its steps
   through to completion (commit, push, PR to main, version bump, release PR, merge,
   verify release).

### Phase 2: Bump Downstream

2. Infer the package name to bump:
   - Check `wally.toml` for the package name (e.g., `horsenuggets/chalk-luau`)
   - Check `rokit.toml` for the tool name if this is a CLI tool
   - If neither exists, use the repo directory name
   - If ambiguous, ask the user

3. Wait for the release to be fully published and available. For GitHub releases, verify
   with `gh release view <version>`. For Wally packages, ensure the release workflow has
   completed.

4. Run `/all /bump <package-name>` to update the dependency across all repos in ~/git.
   For lune, this includes updating both `rokit.toml` and the `.luaurc` typedef alias path
   (see `/bump` for details).

5. Report a final summary:
   - The version that was released
   - Which repos were bumped
   - Any repos that were skipped

## Arguments

- `$ARGUMENTS` - Optional: override the bump level (default: `patch`), or specify the
  package name to bump if it cannot be inferred.
