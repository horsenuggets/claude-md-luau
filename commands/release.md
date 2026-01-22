---
description: Commit, push, and create a release PR with version bump and changelog
---

Automate the full release process: commit changes, push, create a release PR, wait for checks, merge, and verify the release is published.

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

9. Ask the user what type of release this is:
   - **patch**: Bug fixes (0.0.X)
   - **minor**: New features, backwards compatible (0.X.0)
   - **major**: Breaking changes (X.0.0)
   - **custom**: Let user specify exact version

10. Calculate the new version number based on semantic versioning.

11. Update the `VERSION` file with the new version.

12. **IMPORTANT**: Sync the version to `wally.toml` by running:
    ```
    lune run ./Submodules/luau-cicd/Scripts/SyncVersion.luau
    ```
    This script reads the VERSION file and updates wally.toml automatically. The VERSION file and wally.toml must always have matching versions.

13. Update `CHANGELOG.md` with the new version section. Analyze commits since the last release tag to generate changelog entries. Format:
    ```
    ## X.Y.Z
    - Added ...
    - Changed ...
    - Fixed ...
    ```

14. Commit the version bump and changelog update with message: `Bump version to X.Y.Z`

15. Push the changes.

### Phase 3: Merge to Main First

**IMPORTANT**: The release branch must contain exactly what is in main. Changes must be merged to main before creating a release PR.

16. If on a feature branch (not main), first create a PR to main:
    - Create a PR from the feature branch to `main` using `gh prc`
    - Wait for checks to pass
    - Squash merge to main
    - Delete the feature branch

17. Switch to main and pull the latest changes:
    ```
    git checkout main && git pull
    ```

### Phase 4: Create Release PR

**Recommended approach**: Use the `mkrelease` shell function to create the release branch:
```bash
mkrelease X.Y.Z  # Creates release-X.Y.Z branch from main, merges release history, keeps main's content
git push -u origin release-X.Y.Z
gh pr create --base release --title "Release X.Y.Z" --assignee @me
```

The `mkrelease` function handles all the complexity of merging release branch history while ensuring the content matches main exactly.

**Manual approach** (if mkrelease is not available):

18. Create a release branch from main that merges release history:
    ```bash
    git checkout main && git pull
    git checkout -b release-X.Y.Z
    git fetch origin release
    git merge origin/release --no-edit -X ours
    # If merge brought in unwanted changes, reset files to main:
    git diff origin/main --name-only | xargs -I {} git checkout origin/main -- {}
    git add -A && git commit --amend --no-edit
    ```

19. Verify the branch matches main exactly:
    ```bash
    git diff origin/main --stat  # Should show no output
    ```

20. Push and create PR:
    ```bash
    git push -u origin release-X.Y.Z
    gh pr create --base release --title "Release X.Y.Z" --assignee @me
    ```

21. Set the PR title to exactly: `Release X.Y.Z` (where X.Y.Z is the version from the VERSION file).

22. Set the PR body to include:
    ```
    ## Summary
    - Release version X.Y.Z

    ## Changelog
    [Include the changelog entries for this version]
    ```

### Phase 5: Wait for Checks and Iterate

23. Monitor the PR checks using `gh pr checks <PR_NUMBER> --watch` or by polling `gh pr checks <PR_NUMBER>`.

24. If any checks fail:
    - Analyze the failure using `gh pr checks <PR_NUMBER>` and reading the logs
    - Attempt to fix the issue (formatting, tests, linting, etc.)
    - Commit the fix and push
    - Repeat until all checks pass

25. Once all checks pass, squash merge the PR using:
    ```
    gh pr merge <PR_NUMBER> --squash --delete-branch
    ```

### Phase 6: Verify Release

26. Wait a few seconds for GitHub Actions to trigger, then monitor the release workflow:
    ```
    gh run list --workflow=release.yml --limit=1
    gh run watch <RUN_ID>
    ```
    (Adjust workflow name if different in the repo)

27. Once the workflow completes, verify the release was created:
    ```
    gh release view X.Y.Z
    ```

28. Confirm the release is public (not a draft) by checking:
    ```
    gh release view X.Y.Z --json isDraft,isPrerelease
    ```

29. Report the final status to the user:
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

- This command expects a `release` branch to exist for the release workflow
- Version tags should NOT have a "v" prefix (use `0.0.1`, not `v0.0.1`)
- The release workflow is typically triggered by merging to the `release` branch
