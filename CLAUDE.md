# Claude Code Guidelines

Always follow these guidelines strictly and without exception. Before completing any task, verify that all changes adhere to these rules.

## README Format

- The title should be the exact repository name in lowercase kebab-case
- The first sentence of the description must exactly match the GitHub repository description
- Additional details can follow the description (usage examples, etc.)

## Commits

- Always break commits down into logical parts
- Do not co-author yourself in commits

## Formatting

- Run `stylua .` often to ensure that code is formatted properly
- Every file should end in a single newline
- Text should be LF normalized
- Prefer Luau string interpolation using backticks, like `` `Here is a string with an interpolated {value}.` ``
- Prefer double quotes over single quotes
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

## Comments

- All comments should word-wrap at column 90

## Functions

- Always add runtime typechecking to function parameters using assert

## Operators

- Use compound assignment operators (`+=`, `-=`, `*=`, `/=`) instead of expanded form

## Print Statements

- Avoid using colons `:` in prints for stylistic reasons
- Structure everything in complete sentences
- Surround strings of interest in quotation marks `"`
- Use `[Usage]` instead of `Usage:` for usage messages

## Versioning

- Version tags should NOT have a "v" prefix (use `0.0.1`, not `v0.0.1`)

## Changelog Format

CHANGELOG.md should follow this format:

```md
# Changelog

## 0.0.2

### Added

- This is an example addition
- This is another example addition

### Changed

- This is an example change
- This is another example change

### Fixed

- This is an example fix
- This is another example fix

## 0.0.1

### Added

- This is an example addition
- This is another example addition

### Changed

- This is an example change
- This is another example change

### Fixed

- This is an example fix
- This is another example fix
```

## Ordering

- When things can be sorted alphabetically, definitely do that (e.g., imports, table keys, function parameters)

## Tests

- For TestEZ-style tests, do not wrap everything in a describe block with just the file name
- The file name is already used as the test name, so a wrapping describe block is redundant

## Lune Documentation

You can read Lune documentation as needed to understand the Lune code you're writing:

- https://lune-org.github.io/docs/api-reference/fs
- https://lune-org.github.io/docs/api-reference/net
- https://lune-org.github.io/docs/api-reference/process
- https://lune-org.github.io/docs/api-reference/*
