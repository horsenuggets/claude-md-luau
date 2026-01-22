---
description: Push changes and release a patch version
---

Push all uncommitted changes and release a patch version. This is a shortcut for `/push` followed by `/release patch`.

## Instructions

### Phase 1: Commit and Push Changes

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

5. Follow the repository's existing commit message style if one is apparent from `git log`.

6. After all commits are created, push to the remote repository using `git push`. If the branch has no upstream, use `git push -u origin <branch-name>`.

### Phase 2: Version and Changelog

7. Check if a `release` branch exists using `git branch -r | grep release`. If no release branch exists, inform the user and stop.

8. Read the current version from the `VERSION` file (or similar version file in the repo).

9. Bump the **patch** version (0.0.X) automatically. Do not ask the user for confirmation.

10. Update the `VERSION` file with the new version.

11. **IMPORTANT**: Sync the version to `wally.toml` by running:
    ```
    lune run ./Submodules/luau-cicd/Scripts/SyncVersion.luau
    ```
    This script reads the VERSION file and updates wally.toml automatically. The VERSION file and wally.toml must always have matching versions.

12. Update `CHANGELOG.md` with the new version section. Analyze commits since the last release tag to generate changelog entries. Format:
    ```
    ## X.Y.Z
    - Added ...
    - Changed ...
    - Fixed ...
    ```

13. Commit the version bump and changelog update with message: `Bump version to X.Y.Z`

14. Push the changes.

### Phase 3: Merge to Main First

**IMPORTANT**: The release branch must contain exactly what is in main. Changes must be merged to main before creating a release PR.

15. If on a feature branch (not main), first create a PR to main:
    - Create a PR from the feature branch to `main` using `gh prc`
    - Wait for checks to pass
    - Squash merge to main
    - Delete the feature branch

16. Switch to main and pull the latest changes:
    ```
    git checkout main && git pull
    ```

### Phase 4: Create Release PR

17. If a `pre-release` branch exists:
    - Reset `pre-release` to match main: `git checkout pre-release && git reset --hard main`
    - Merge `release` into `pre-release` to handle any conflicts
    - Resolve conflicts if any arise (prefer main's content for version/changelog)
    - Push `pre-release` with force: `git push --force origin pre-release`
    - Create a PR from `pre-release` to `release` using `gh prc`

    If no `pre-release` branch exists:
    - Create a PR directly from `main` to `release` using `gh prc`

18. Set the PR title to exactly: `Release X.Y.Z` (where X.Y.Z is the version from the VERSION file).

19. Set the PR body to include:
    ```
    ## Summary
    - Release version X.Y.Z

    ## Changelog
    [Include the changelog entries for this version]
    ```

### Phase 5: Wait for Checks and Iterate

20. Monitor the PR checks using `gh pr checks <PR_NUMBER> --watch` or by polling `gh pr checks <PR_NUMBER>`.

21. If any checks fail:
    - Analyze the failure using `gh pr checks <PR_NUMBER>` and reading the logs
    - Attempt to fix the issue (formatting, tests, linting, etc.)
    - Commit the fix and push
    - Repeat until all checks pass

22. Once all checks pass, squash merge the PR using:
    ```
    gh pr merge <PR_NUMBER> --squash --delete-branch
    ```

### Phase 6: Verify Release

23. Wait a few seconds for GitHub Actions to trigger, then monitor the release workflow:
    ```
    gh run list --workflow=release.yml --limit=1
    gh run watch <RUN_ID>
    ```
    (Adjust workflow name if different in the repo)

24. Once the workflow completes, verify the release was created:
    ```
    gh release view X.Y.Z
    ```

25. Report the final status to the user:
    - Release version
    - Release URL: `gh release view X.Y.Z --json url -q .url`
    - Whether release is public
    - Any issues encountered

## Error Handling

- If the release workflow fails, analyze the error and report it to the user
- If the release is created as a draft, inform the user they may need to publish it manually
- If checks keep failing after 3 attempts, ask the user for guidance
- Always clean up: if you created temporary branches, offer to delete them

## Notes

- This command always does a **patch** release. For minor or major releases, use `/release minor` or `/release major` instead.
- Version tags should NOT have a "v" prefix (use `0.0.1`, not `v0.0.1`)
- The release workflow is typically triggered by merging to the `release` branch
