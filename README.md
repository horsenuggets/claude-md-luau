# claude-md-luau

Luau-specific Claude Code guidelines for Roblox and Lune projects.

## Overview

This repository extends [claude-md](https://github.com/horsenuggets/claude-md) with
Luau-specific coding standards, including:

- **Formatting** - stylua, string interpolation, quoting conventions
- **File Headers** - Standard Luau file header format
- **Naming Conventions** - PascalCase modules, camelCase functions, class patterns
- **Moonwave Documentation** - Doc comment standards
- **Module Structure** - @self usage and init.luau patterns
- **Testing** - TestEZ conventions
- **Tooling** - Lune, Rokit, Wally configuration

## Usage

This repository is designed to be used as a submodule alongside claude-md:

```bash
git submodule add https://github.com/horsenuggets/claude-md-luau.git Submodules/claude-md-luau
```

## Slash Commands

| Command           | Description                  |
| ----------------- | ---------------------------- |
| `/template [cmd]` | Manage luau-package-template |

## License

MIT
