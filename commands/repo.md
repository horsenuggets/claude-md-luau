---
description: Work in a specific repository, checking ~/git first
---

The user wants you to work in the repository: $ARGUMENTS

First, search in ~/git to find if this repository is already cloned. Use `fd -t d -H "^\.git$" ~/git -x dirname {}` to locate git repos, then match against the repository name.

If found, cd into that directory and proceed with the user's request.
If not found, ask the user where they would like you to clone it.
