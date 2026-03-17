# Luau Guidelines

These guidelines supplement the general Claude Code guidelines from
[claude-md](https://github.com/horsenuggets/claude-md). Always follow both sets of guidelines.

## Formatting

- Run `stylua .` often to ensure that Luau code is formatted properly
- Prefer string interpolation using backticks over the `..` concatenation operator, like `` `Here is a string with an interpolated {value}.` ``
- Prefer double quotes over single quotes
- Multi-line strings using `[[...]]` should be indented with the rest of the code, even if this adds leading whitespace to the string content

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

Executable Lune scripts in `Scripts/` must have the executable bit set and start with a
shebang line (`#!/usr/bin/env -S lune run`). Always run them directly (e.g.,
`./Scripts/RunTests.luau`) instead of using `lune run`.

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

## Configuration Files

In `rokit.toml` and `wally.toml`, repository names using the `username/project` format should
always be lowercase (e.g., `horsenuggets/testable`, not `HorseNuggets/Testable`).

In `.luaurc`, do not add `@self` as an alias. It is already built-in and refers to the current
module.

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

## Ordering

- Constants (like `local THIS_IS_A_CONSTANT`) should be placed above the module definition
  (like `local MyModule = {}`)

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

## Static Analysis with luau-lsp

Use `luau-lsp analyze` to type-check and lint Luau source files. Projects using the
luau-cicd submodule already have this integrated via `./Scripts/RunStaticAnalysis.luau`.

### Basic usage

```bash
# Standard Luau project (no Roblox types)
luau-lsp analyze --platform=standard .

# Roblox project (built-in PluginSecurity definitions are loaded automatically)
luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json .

# Lune project (built-in Lune globals)
luau-lsp analyze --platform=lune .
```

### Common flags

- `--platform=standard|roblox|lune` - Load platform-specific type definitions
- `--sourcemap=sourcemap.json` - Rojo sourcemap for DataModel-aware resolution
- `--ignore "Packages/**"` - Ignore glob patterns (repeat for multiple)
- `--no-flags-enabled` - Disable all Luau FFlags (useful for deterministic CI)
- `--definitions=path.d.luau` - Load custom type definitions (overrides built-in)
- `--formatter=gnu` - GNU-style error format for editor integration

### Typical CI invocation

```bash
luau-lsp analyze \
  --platform=lune \
  --ignore "Packages/**" \
  --ignore "DevPackages/**" \
  --ignore "Submodules/**" \
  --no-flags-enabled \
  .
```

The exit code is non-zero if any errors are found. Warnings alone do not cause failure
unless the project's `.luaurc` promotes them to errors.

### Roblox projects

For Roblox projects, generate a sourcemap first with `rojo sourcemap default.project.json
--output sourcemap.json`, then pass `--sourcemap=sourcemap.json`. The fork's built-in
Roblox definitions mean you no longer need `--definitions` for standard type checking.

## Custom Slash Commands

### Available Commands

- `/template [update|sync]` - Manage luau-package-template and sync changes
