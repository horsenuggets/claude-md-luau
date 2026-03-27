---
description: Make a change to a dependency, release it, and bump it across all repos
---

Make a change to the specified dependency, release it, and update all downstream repos.

## Arguments

The first argument is the package/repo name (e.g., `commandline-luau`, `chalk-luau`).
Everything after is the change description.

Example: `/upstream commandline-luau sort flags alphabetically in help output`

## Instructions

1. Find the repo by searching ~/git recursively for a directory matching the package name
2. Navigate to it and make the described change
3. Create a feature branch, commit, push, and PR to main. Watch CI checks and wait for
   GitHub Copilot's code review before merging. Address any review feedback if needed.
   If main is not protected, push directly instead.
4. Run `/release patch` to bump the version, update changelog, and create a release PR
5. After the release is published, run `/all /bump <wally-package-name>` to update all
   downstream repos

$ARGUMENTS
