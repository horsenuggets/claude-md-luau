# Luau Guidelines

These guidelines supplement the general Claude Code guidelines from
[claude-md](https://github.com/horsenuggets/claude-md). Always follow both sets of guidelines.

## Terminology

- Always use "Luau" (not "Lua") when referring to the Roblox programming language
- "Roblox Luau", never "Roblox Lua"
- Use ````luau` for markdown code block syntax hints, never ````lua`
- "Luau code", "Luau file", "Luau script", "Luau module", "Luau runtime"
- The only exception is `.lua` file extensions and tool names like `stylua`

## Formatting

- Run `stylua .` often to ensure that Luau code is formatted properly
- Prefer string interpolation using backticks over the `..` concatenation operator, like `` `Here is a string with an interpolated {value}.` ``
- Prefer double quotes over single quotes
- Multi-line strings using `[[...]]` should be indented with the rest of the code, even if this adds leading whitespace to the string content
- When any key in a table literal requires bracket-quote syntax (e.g., `["or"]` for Luau
  keywords), use `["key"]` syntax for ALL keys in that table for consistency

### Requires

Always use require-by-string (e.g., `require("@packages/Fusion")`, `require("@self/Module")`, `require("./Sibling")`) instead of instance-based requires (e.g., `require(script.Parent.Module)`). Require-by-string is superior in every way.

## Luau File Headers

Every Luau file should have this at the top:

```luau
--[[

<File name without .luau extension>

<Description in a few sentences, wrapping by word at column 90>

--]]
```

The name in the header is the full file name with `.luau` removed. For files with
sub-extensions like `.spec.luau`, `.story.luau`, or `.storybook.luau`, keep the
sub-extension in the header (e.g., `MyModule.spec`, `PromptInput.story`).

For `init.luau` files (and Rojo variants like `init.server.luau`, `init.client.luau`,
`init.plugin.luau`), use the parent folder name instead of "init".

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

### Windows Setup

On Windows, there is no shebang support. To make `./Scripts/Foo.luau` work in PowerShell,
register a file association for `.luau` files. Run this once in an elevated PowerShell
session:

```powershell
cmd /c 'assoc .luau=LuauScript'
cmd /c 'ftype LuauScript=lune run "%1" %*'
```

This tells Windows to run `.luau` files through `lune run`, equivalent to what the shebang
does on macOS/Linux. After this, `./Scripts/Foo.luau` works in PowerShell the same way it
does in zsh/bash.

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

### Table Keys and Type Fields

All keys in dictionary-style table literals and fields in type definitions must use
PascalCase. This applies to config tables, data structures, return values, and any
table with named keys:

```luau
-- GOOD
export type Config = {
    ApiKeyEnvName: string?,
    Assets: string,
    Creator: CreatorConfig,
}

local state = {
    CurrentPhase = "lobby",
    RoundNumber = 0,
}

-- BAD
export type Config = {
    apiKeyEnvName: string?,
    assets: string,
    creator: CreatorConfig,
}

local state = {
    currentPhase = "lobby",
    roundNumber = 0,
}
```

The only exception is tables whose keys must match an external API's JSON field names
(e.g., Open Cloud request/response bodies).

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

    ```luau
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

- Always add runtime typechecking to function parameters using the `t` library
  (if it's a project dependency) with `assert(t.type(param))`. For projects
  without `t`, use `assert(type(param) == "string")` style checks instead.
- Add `t` checks to all public API functions and key internal functions that
  accept parameters from external callers
- Use `t.interface()` for validating table/config parameters with known shapes
- Use `t.optional()` for nullable parameters
- Use `t.array()` for array parameters with element type validation
- Use Roblox-specific type checkers for Roblox datatypes: `t.Font`, `t.Color3`,
  `t.Instance`, `t.Vector3`, `t.UDim2`, `t.CFrame`, `t.Enum`, `t.EnumItem`,
  etc. Do NOT use `t.table` or `t.any` for these — they are userdata, not tables
- Keep `t` checks at the top of functions, before any logic

## Configuration Files

In `rokit.toml` and `wally.toml`, repository names using the `username/project` format should
always be lowercase (e.g., `johnnymorganz/stylua`, not `JohnnyMorganz/StyLua`).

In `.luaurc`, do not add `@self` as an alias. It is already built-in and refers to the current
module.

## Tests

- Always add tests for new behavior, especially when modifying analysis, linting, or
  type-checking logic. If you add a feature, add a test that verifies it works and a
  negative test that verifies it doesn't false-trigger.
- For TestEZ-style tests, do not wrap everything in a describe block with just the file name
- The file name is already used as the test name, so a wrapping describe block is redundant

## Code Reuse

- Never duplicate function definitions across files. If the same logic is needed in
  multiple places (e.g., a script and a command, or a command and a demo), extract it into
  a shared helper module and import it everywhere. This applies to utility functions,
  formatting logic, rendering code, color calculations, etc.
- Scripts in `Scripts/` should import from `Source/` helpers, not copy their implementations.

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

## Knowledge Reference

The `knowledge/` directory contains reference data for Roblox/Luau development:

- `knowledge/roblox-fonts.md` - Complete list of all Roblox fonts with asset IDs
- `knowledge/roblox-open-cloud-places.md` - Creating, publishing, and testing Roblox places via API

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

**Run `luau-lsp analyze` frequently while working** — after making changes, before
committing, and especially before pushing. Treat it like running tests. Do not wait
until CI to discover type errors. If a project has `./Scripts/RunStaticAnalysis.luau`,
use that. Otherwise run `luau-lsp analyze` directly with the appropriate platform flag.

**Warnings are errors.** CI rejects on any diagnostic output, including warnings like
`ImportUnused` and `LocalUnused`. Fix all warnings before committing — do not leave
unused imports, unused variables, or any other warnings in the code.

Most projects have both Lune code (scripts in `Scripts/`) and Roblox code (source in
`Source/`). These require different platforms because they have different globals and type
definitions.

### Lune projects and scripts

Lune code uses `--platform=lune` which provides built-in globals like `process`, `fs`,
`net`, `task`, `stdio`, etc. This is the right platform for anything in `Scripts/` and
for standalone Lune packages that don't use Roblox APIs.

```bash
luau-lsp analyze \
  --platform=lune \
  --no-flags-enabled \
  --ignore "Packages/**" \
  --ignore "DevPackages/**" \
  --ignore "Submodules/**" \
  Scripts/
```

### Roblox projects

Roblox code uses `--platform=roblox` which auto-loads PluginSecurity-level type
definitions (Instance, UDim2, Color3, Enum, game, workspace, etc.). No `--definitions`
flag is needed — the fork embeds them at build time.

Roblox projects also need a Rojo sourcemap for proper module resolution. Generate one
first, then pass it:

```bash
rojo sourcemap default.project.json --output sourcemap.json

luau-lsp analyze \
  --platform=roblox \
  --sourcemap=sourcemap.json \
  --no-flags-enabled \
  --ignore "Packages/**" \
  --ignore "DevPackages/**" \
  --ignore "Submodules/**" \
  Source/
```

The sourcemap enables DataModel-aware require resolution, including Wally packages that
use `default.project.json` with `$path` redirects (e.g., Fusion).

### Mixed projects (Lune + Roblox)

Many projects have both Lune scripts and Roblox source. Run analyze twice with different
platforms targeting different directories:

```bash
# Analyze Lune scripts
luau-lsp analyze --platform=lune --no-flags-enabled \
  --ignore "Packages/**" --ignore "DevPackages/**" \
  Scripts/

# Analyze Roblox source
luau-lsp analyze --platform=roblox --no-flags-enabled \
  --sourcemap=sourcemap.json \
  --ignore "Packages/**" --ignore "DevPackages/**" \
  Source/
```

### Common flags

- `--platform=standard|roblox|lune` - Load platform-specific type definitions
- `--sourcemap=sourcemap.json` - Rojo sourcemap for DataModel-aware resolution
- `--ignore "glob"` - Ignore glob patterns (repeat for multiple)
- `--no-flags-enabled` - Disable all Luau FFlags (useful for deterministic CI)
- `--definitions=path.d.luau` - Load custom type definitions (overrides built-in)
- `--formatter=gnu` - GNU-style error format for editor integration

### Exit codes

The exit code is non-zero if any errors are found. Warnings alone do not cause failure
unless the project's `.luaurc` promotes them to errors.

## Roblox Studio MCP

When working on Roblox projects, you can interact with a running Roblox Studio instance via
the RobloxStudio MCP server. This is useful for visually verifying UI changes, inspecting the
game tree, reading scripts, and more.

### UI Labs Shared API

The fork of UI Labs exposes a
`shared.UILabs` API that allows programmatic story management from `execute_luau`:

```luau
-- List all available stories
local stories = shared.UILabs.listStories()
-- Returns: { { name: string, path: string, module: ModuleScript }, ... }

-- Mount a story by name (blocks until rendered, up to 5s)
local holder = shared.UILabs.mountStory("SetKeyPrompt")
-- Returns: Frame (the rendered story container) or nil

-- Get the holder of an already-mounted story
local holder = shared.UILabs.getStoryHolder("SetKeyPrompt")

-- List currently mounted stories
local mounted = shared.UILabs.getMountedStories()

-- Unmount a story
shared.UILabs.unmountStory("SetKeyPrompt")
```

UI Labs must be open in Studio for the API to be available. The stories are
discovered from Rojo serve sessions (e.g., `rojo serve storybook.project.json`).

To rebuild and install the fork, run `pnpm install && npx rbxtsc && rojo build
default.project.json --output UILabs.rbxm` from the ui-labs repo, then copy
`UILabs.rbxm` to the Studio plugins folder.

### Restarting Plugins

Studio watches the plugins folder and automatically reloads plugins when files
change. To restart a plugin programmatically, move the `.rbxm` file out of the
plugins folder and back in:

```bash
mv <plugins-folder>/UILabs.rbxm /tmp/UILabs.rbxm
sleep 2
mv /tmp/UILabs.rbxm <plugins-folder>/UILabs.rbxm
```

This works for any plugin — Rojo, UI Labs, etc. The 2-second delay ensures
Studio detects the removal before the file reappears.

### Rojo Shared API

The fork of Rojo exposes a `shared.Rojo` API that allows programmatic
plugin control from `execute_luau`. This is essential for automated workflows — it
eliminates the need to manually click Connect/Accept in the Rojo plugin UI.

```luau
-- Connect and auto-accept in one call (recommended)
local result = shared.Rojo.connectAndAccept()
-- Optional: specify host, port, timeout
local result = shared.Rojo.connectAndAccept("localhost", "34872", 10)
-- Returns: { success: bool, projectName?: string, address?: string,
--            error?: string }

-- Connect without auto-accept (will pause at Confirming state)
shared.Rojo.connect("localhost", "34872")

-- Accept/abort a pending sync confirmation
shared.Rojo.accept()
shared.Rojo.abort()

-- Disconnect from the current session
shared.Rojo.disconnect()

-- Check connection status
local status = shared.Rojo.getStatus()
-- Returns: { status: string, projectName?: string, address?: string,
--            error?: string }
-- Status values: "NotConnected", "Connecting", "Confirming",
--                "Connected", "Error", "Unloaded"

-- Get current host and port
local addr = shared.Rojo.getAddress()
-- Returns: { host: string, port: string }

-- Clear known projects cache (forces confirmation dialog to
-- appear even with "Initial" confirmation behavior)
shared.Rojo.clearKnownProjects()
```

The API is only available in edit mode (not during play tests). It registers
automatically when the plugin loads and cleans up on unload.

To rebuild and install the fork, run `rojo build plugin.project.json --output Rojo.rbxm`
from the rojo repo, then copy `Rojo.rbxm` to the Studio plugins folder.

**Important:** Rojo projects that need the shared API to work must have HTTP
enabled. Add this to the project JSON:
```json
"HttpService": {
    "$className": "HttpService",
    "$properties": {
        "HttpEnabled": true
    }
}
```

### Capturing Screenshots

Use `mcp__RobloxStudio__screen_capture` with a `capture_id` parameter (e.g.,
`"ScreenCapture_1"`) to capture the current Studio viewport. This returns an image you can
view directly. Use it to verify UI components, plugin widgets, and visual changes.

To screenshot a UI Labs story, use `renderStory` then capture:

```luau
-- Renders story into CoreGui with dotted background (auto-cleans
-- after 30s via Debris)
shared.UILabs.renderStory("SetKeyPrompt")
-- Optional: pass width, height overrides
shared.UILabs.renderStory("SetKeyPrompt", 400, 350)
```

Then call `mcp__RobloxStudio__screen_capture` to capture the viewport. The render
auto-destroys after 30 seconds, or you can manually remove it:

```luau
local gui = game:GetService("CoreGui"):FindFirstChild("UILabsRender")
if gui then gui:Destroy() end
```

### Other Useful Tools

- `mcp__RobloxStudio__list_roblox_studios` - List connected Studio instances
- `mcp__RobloxStudio__set_active_studio` - Switch active Studio instance
- `mcp__RobloxStudio__search_game_tree` - Search the Explorer tree
- `mcp__RobloxStudio__inspect_instance` - Inspect instance properties
- `mcp__RobloxStudio__script_read` - Read a script's source
- `mcp__RobloxStudio__script_grep` - Search across scripts
- `mcp__RobloxStudio__execute_luau` - Run Luau code in Studio
- `mcp__RobloxStudio__get_console_output` - Read the output console

These tools are deferred — use `ToolSearch` to fetch their schemas before calling them.

### Clearing Studio Output

Use `LogService:ClearOutput()` to clear the output log before checking for new
errors. This avoids confusion from stale log entries:

```luau
local LogService = game:GetService("LogService")
LogService:ClearOutput()
```

### Reading Studio Output

The `get_console_output` tool often returns empty. If it does, use `execute_luau` with
LogService to read the output history directly:

```luau
local LogService = game:GetService("LogService")
local history = LogService:GetLogHistory()
local results = {}
for i = math.max(1, #history - 50), #history do
    local entry = history[i]
    if entry then
        table.insert(results, `[{entry.messageType}] {entry.message}`)
    end
end
if #results == 0 then
    return "No log entries found."
end
return table.concat(results, "\n")
```
