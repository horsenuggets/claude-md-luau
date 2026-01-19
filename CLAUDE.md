# Claude Code Guidelines

Always follow these guidelines strictly and without exception. Before completing any task, verify that all changes adhere to these rules.

## Task Completion

When a user queues multiple tasks in a single message (like "do X, then /commit, /push, /release"), follow through on all queued tasks automatically without requiring additional reminders.

## CRITICAL: No Hardcoded Paths

NEVER hardcode user-specific or machine-specific paths. This is absolutely unacceptable and unprofessional. Examples of what to NEVER do:

- Home directories: `/home/chris`, `/home/username`, `/Users/username`
- Tool storage paths: `~/.rokit/tool-storage/username/toolname/version/binary`
- Any absolute path that only exists on one specific machine

Always use:

- Environment variables (e.g., `process.env.HOME`)
- Relative paths
- Tool shims that resolve paths dynamically (e.g., just `lune` instead of the full path)
- Standard system paths that exist on all machines

Code must work on any machine, including CI environments. If you find yourself typing a username or a path from your local machine, stop immediately.

## README Format

- The title should be the exact repository name in lowercase kebab-case
- The first sentence of the description must exactly match the GitHub repository description
- Additional details can follow the description (usage examples, etc.)

## Git Workflow

When the user mentions a repository, always check recursively in `~/git` to see if it is
already cloned before cloning it elsewhere.

Never work inside a submodule directory. Instead, find the standalone repository in `~/git`
and make changes there.

### Branch Strategy

- **main**: Protected branch, requires PR with passing checks, squash merge only
- **release**: Protected branch, requires PR with passing checks, squash merge only
- **pre-release**: Used to resolve merge conflicts before PRing to release

### Branch Naming

Feature branches must follow this format: `<prefix>/<lowercase-kebab-case-name>`

Valid prefixes:
- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Urgent fixes
- `chore/` - Maintenance tasks
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or modifications

Examples:
- `feature/add-dark-mode`
- `bugfix/fix-login-error`
- `chore/update-dependencies`

**Important**: Do NOT use dots in branch names. Version numbers like `0.1.0` are not valid in
the suffix. Use `chore/bump-version` instead of `chore/release-0.1.0`.

### Development Workflow

1. Create a feature branch from main (e.g., `feature/my-feature`)
2. Make changes and commit
3. Create a PR to main
4. PR must pass all checks (format, test, static analysis, branch naming)
5. Squash merge to main
6. Switch back to main branch when done

### Release Workflow

1. Update VERSION file with new version
2. Update CHANGELOG.md with release notes
3. Create or update `pre-release` branch from main
4. Merge `release` into `pre-release` to handle any conflicts
5. Resolve conflicts if any
6. Create a PR from `pre-release` to `release`
7. PR title must be exactly `Release X.Y.Z` (matching the VERSION file)
8. PR description should only contain Summary and Changelog sections (no "Test plan" checkboxes)
9. PR must pass all checks including:
   - All standard checks (format, test, static analysis)
   - Version validation (proper semver bump)
   - Changelog entry validation
   - Diff check (PR content must match main exactly)
10. Squash merge to release
11. GitHub Actions automatically creates the release and tag

**Branch protection note**: If merge fails with "required status checks are expected", the
branch protection rules may have outdated check names. Check names must match the `name:`
field in workflow jobs (e.g., "Check formatting" not "format").

### PR Creation

When creating a GitHub PR, always use `gh prc` instead of `gh pr create`. This alias
automatically adds the user as an assignee. All other flags work the same way (e.g.,
`gh prc --base main --title "My PR"`).

### PR Monitoring

After opening a PR, continuously monitor its status until it is merged:

1. Watch for CI check results
2. If checks fail, investigate the failure, fix the issue, and push updates
3. Keep iterating until all checks pass
4. Wait for GitHub Copilot's review before merging (manually request a review from Copilot if
   needed)
5. Once all checks pass and Copilot has reviewed, merge immediately
6. Do not abandon a PR mid-process; see it through to completion

### Concurrent Work

Before making changes to a repository, check if another Claude instance is already working
there. If so, create a temporary worktree in `~/git/worktrees` for that repo so you can work
seamlessly without conflicts.

## Commits

- Always break commits down into logical parts
- Do not co-author yourself in commits
- Use sentence case for commit messages (start with a capital letter)
- Do NOT use conventional commit prefixes like `test:`, `chore:`, `feat:`, `fix:`, etc.

## Formatting

- Run `stylua .` often to ensure that Luau code is formatted properly
- Run `prettier --write "**/*.json"` to format all JSON files (respects `.editorconfig`)
- Every file should end in a single newline
- Text should be LF normalized
- Prefer string interpolation using backticks over the `..` concatenation operator, like `` `Here is a string with an interpolated {value}.` ``
- Prefer double quotes over single quotes
- Multi-line strings using `[[...]]` should be indented with the rest of the code, even if this adds leading whitespace to the string content
- Group all constants together without blank lines between them
- Always read through existing code to match style

## Luau File Headers

Every Luau file should have this at the top:

```luau
--[[

<File name without extension>

<Description in a few sentences, wrapping by word at column 90>

--]]
```

For `init.luau` files, use the parent folder name instead of "init".

The exception is the root-level `init.luau` file in packages, which is just a re-export for
package consumers and does not need a header.

## Naming Conventions

### File Names

- PascalCase for modules (e.g., `MyModule.luau`)
- camelCase if the file returns a function (e.g., `doSomething.luau`)
- PascalCase for executable Lune scripts (e.g., `RunTests.luau`)

### Executable Files

For executable Lune scripts, declare a local function with the file name in camelCase, then
call it at the bottom:

```luau
local function runTests()
    -- implementation
end

runTests()
```

### Modules

For standard modules (PascalCase file names):

- Functions: camelCase (e.g., `Module.doSomething()`)
- Properties: PascalCase (e.g., `Module.SomeValue`)
- Constructors: camelCase (e.g., `Module.new()`, `Module.create()`)

### Classes

For classes (modules using metatables to instantiate):

- Methods: PascalCase (e.g., `Class.DoSomething`)
- Static methods/functions: camelCase (e.g., `Class.new()`, `Class.fromData()`)
- Instance properties: PascalCase
- Static properties: PascalCase

Define methods using dot syntax with explicit `self` parameter:

```luau
function Class.DoSomething(self: Class, value: number)
    -- implementation
end
```

Prefer explicit `export type` for the class type:

```luau
export type Class = {
    Value: number,
    DoSomething: (self: Class, value: number) -> (),
}
```

### Internal/Private Members

Internal methods, functions, and properties start with `_` followed by camelCase. This
overrides the above rules:

- Internal method: `_doInternalThing`
- Internal property: `_internalValue`
- Internal function: `_helperFunction`

## Comments

- All comments should word-wrap at column 90 (wrap at word boundaries, never mid-word)
- In block comments, use `> ` prefix for list items instead of indentation with spaces (e.g.,
  `> DISCORD_BOT_TOKEN - description` instead of `  DISCORD_BOT_TOKEN - description`)

## Moonwave Documentation

Use Moonwave doc comments for API documentation. Doc comments use `--[=[` and `]=]` (not
regular `--[[`).

### Class Documentation

```luau
--[=[
    @class ClassName
    @tag class|structure|enum

    Description of the class.

    ```lua
    -- Example usage code
    ```
]=]
local ClassName = {}
```

### Function/Method Documentation

```luau
--[=[
    Description of the function.

    @param paramName ParamType -- Description of parameter
    @param optionalParam ParamType? -- Optional parameter
    @return ReturnType -- Description of return value
]=]
function ClassName.MethodName(self: ClassName, paramName: ParamType): ReturnType
```

### Property Documentation

```luau
--[=[
    @prop PropertyName Type
    Description of the property.
]=]
```

### Building Documentation

Run `moonwave build --code Source` to generate docs (specify source directory explicitly).
Moonwave defaults to `src` or `lib`, so projects using `Source` must specify `--code Source`.

In `moonwave.toml`, do not add a manual GitHub navbar item - Moonwave automatically adds one
from `gitRepoUrl`.

## Functions

- Always add runtime typechecking to function parameters using assert

## Operators

- Use compound assignment operators (`+=`, `-=`, `*=`, `/=`) instead of expanded form

## Print Statements

- Avoid using colons `:` in prints for stylistic reasons
- Structure everything in complete sentences
- Surround strings of interest in quotation marks `"`
- Use `[Usage]` instead of `Usage:` for usage messages
- Handle singular vs plural properly when displaying counts (e.g., "1 second" vs "2 seconds", "1 test suite" vs "2 test suites")

## Configuration Files

In `rokit.toml` and `wally.toml`, repository names using the `username/project` format should
always be lowercase (e.g., `horsenuggets/testable`, not `HorseNuggets/Testable`).

In `.luaurc`, do not add `@self` as an alias. It is already built-in and refers to the current
module.

## Versioning

- Version tags should NOT have a "v" prefix (use `0.0.1`, not `v0.0.1`)
- Do NOT manually create tags - CI automatically creates tags when releasing
- Do NOT manually create GitHub releases - always let the publish workflow create them
  automatically. If the workflow fails, fix the issue and re-run the workflow.

## Changelog Format

CHANGELOG.md should follow this format:

```md
# Changelog

## 0.0.2
- Added a thing
- Changed a thing
- Fixed a thing

## 0.0.1
- Added a thing
- Changed a thing
- Fixed a thing
```

## Ordering

- When things can be sorted alphabetically, definitely do that (e.g., imports, table keys, function parameters)
- Constants (like `local THIS_IS_A_CONSTANT`) should be placed above the module definition (like `local MyModule = {}`)

## Tests

- For TestEZ-style tests, do not wrap everything in a describe block with just the file name
- The file name is already used as the test name, so a wrapping describe block is redundant

## Module Structure and @self

In Roblox, Scripts can have other Scripts as children. For example, a Script can contain a
ModuleScript, and you can access it via `script.ModuleScript`. This parent-child relationship
is a fundamental pattern in Roblox development.

When syncing to the filesystem, the OS doesn't support putting a file as a child of another
file. Instead, we use the `Dir/init.luau` pattern to mimic this behavior:

- A directory with an `init.luau` file is treated as a single module
- The directory name becomes the module name
- Files inside the directory are "child scripts" of that module
- `@self` refers to the directory containing the `init.luau`

### Example Structure

```
MyModule/
├── init.luau       -- The main module (like Script in Roblox)
├── Helper.luau     -- Child module (like script.Helper)
└── Utils/
    └── init.luau   -- Nested child module (like script.Utils)
```

### Using @self

The `@self` alias should only be used inside `init.luau` files. It refers to the directory
containing the `init.luau`, allowing you to require sibling files:

```luau
-- Inside MyModule/init.luau
local Helper = require("@self/Helper")        -- MyModule/Helper.luau
local Utils = require("@self/Utils")          -- MyModule/Utils/init.luau
```

This is equivalent to `script.Helper` and `script.Utils` in Roblox.

### Rules for @self

- Only use `@self` in `init.luau` files
- `@self` refers to the parent directory of the `init.luau` file
- For non-init files, use relative paths (`./sibling`) instead
- Never use `@self` in regular `.luau` files that are not `init.luau`

### Relative Requires from init.luau

In an `init.luau` file, relative requires like `./foo` resolve relative to the parent
directory (where the module would be imported from), not the directory containing the
`init.luau`. Use `@self/foo` to require files in the same directory as the `init.luau`.

## Tools

- Use `fd` instead of `find`
- Use `rg` (ripgrep) instead of `grep`
- Feel free to add new functions to `~/.zshrc` and new aliases to `~/.aliases` to improve
  workflow efficiency

## Custom Slash Commands

Custom slash commands are stored as Markdown files in `~/.claude/commands/`. Each command is a
`.md` file with YAML frontmatter containing `description:` followed by the command instructions.
The filename (without `.md`) becomes the command name (e.g., `ship.md` creates `/ship`).

## Lune Documentation

You can read Lune documentation as needed to understand the Lune code you're writing:

- https://lune-org.github.io/docs/api-reference/datetime/
- https://lune-org.github.io/docs/api-reference/fs/
- https://lune-org.github.io/docs/api-reference/luau/
- https://lune-org.github.io/docs/api-reference/net/
- https://lune-org.github.io/docs/api-reference/process
- https://lune-org.github.io/docs/api-reference/regex/
- https://lune-org.github.io/docs/api-reference/roblox/
- https://lune-org.github.io/docs/api-reference/serde/
- https://lune-org.github.io/docs/api-reference/stdio/
- https://lune-org.github.io/docs/api-reference/task/
