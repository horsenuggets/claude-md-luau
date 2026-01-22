---
description: Double-check current work against all guidelines in ~/git/claude-md-luau/CLAUDE.md
---

Review the current work in progress and verify compliance with ALL guidelines in ~/git/claude-md-luau/CLAUDE.md.

For each relevant section, check:

1. **No Hardcoded Paths** - Are there any user-specific or machine-specific paths?
2. **README Format** - Does the title match the repo name? Does the first sentence match the GitHub description?
3. **Git Workflow** - Correct branch naming? Following the branch strategy?
4. **Commits** - Are commits broken into logical parts?
5. **Formatting** - Is code formatted with stylua? JSON with prettier? Proper line endings?
6. **Luau File Headers** - Do all Luau files have proper headers?
7. **Naming Conventions** - Correct casing for files, functions, methods, properties?
8. **Comments** - Word-wrapped at column 90? Using `> ` for list items?
9. **Functions** - Runtime typechecking with assert on parameters?
10. **Operators** - Using compound assignment operators?
11. **Print Statements** - No colons, complete sentences, quoted strings?
12. **Configuration Files** - Lowercase repo names in rokit.toml/wally.toml?
13. **Versioning** - No "v" prefix on versions?
14. **Changelog Format** - Following the correct format?
15. **Ordering** - Alphabetical sorting where applicable? Constants above module definition?
16. **Tests** - No redundant wrapping describe blocks?
17. **Module Structure** - Correct use of @self only in init.luau files?

Report any violations found and suggest fixes. If everything looks good, confirm compliance.
