## Coding

### General

- Lua: 2-space indentation, no tabs; prefer `local` scope.
- Module files: snake_case (e.g., `treesitter.lua`, `python_lsp.lua`).
- One plugin/topic per file under `lua/plugins/`; return a config/spec table.
- Keep keys, keymaps, and autocommands grouped and documented at the top level modules.
- Run `stylua` before committing.
- Module pattern: `local M = {}` and `return M`
- Import style: `local module = require("neoment.module")`
- Function docs: Use `---` comments with `@param` and `@return` annotations
- Type annotations: Use `--- @type` and `--- @class` for LSP support
- Async patterns: Use `vim.schedule()` for UI updates from async contexts
- File organization: One module per file, grouped by functionality
- Vim API: Prefer `vim.api.*` over legacy `vim.fn.*` where possible
- Maintain compatibility with Neovim's floating window API
- Prefer local function name() ... end instead of local name = function() ... end.

### Style & Naming Conventions

*   **Naming:** Use snake_case for variables/functions, PascalCase for classes
*   **Modern Lua:** Keep Lua modules modern and isolated. Use `require` for dependencies and avoid global variables.
*   **No License Headers:** Do not add license headers to new files to keep them simple and minimal.
*   **Function Documentation:** Add a comment on top of each function describing its inputs, outputs, and intent. Keep these comments updated when the function's interface or implementation changes.
*   **Line Length:** Keep comments and code within 120 columns for better readability. Break long lines as needed.


### Commit Messages

All commit messages should follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification. This creates a more readable and structured commit history.

#### Format

Each commit message consists of a **header**, a **body**, and a **footer**.

```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

*   **type**: Must be one of the following:
    *   `feat`: A new feature
    *   `fix`: A bug fix
    *   `docs`: Documentation only changes
    *   `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
    *   `refactor`: A code change that neither fixes a bug nor adds a feature
    *   `perf`: A code change that improves performance
    *   `test`: Adding missing tests or correcting existing tests
    *   `chore`: Changes to the build process or auxiliary tools and libraries such as documentation generation
*   **scope**: (Optional) A noun specifying the part of the codebase affected by the change (e.g., `sidebar`, `diff`, `mcp`).
*   **description**: A concise description of the change in the present tense.
*   **body**: (Optional) A longer description of the change, providing more context.
*   **footer**: (Optional) Contains any information about breaking changes or references to issues.

#### Example

```
feat(sidebar): Add toggle functionality

The new `toggle` function allows the user to open and close the sidebar
with a single command. This improves user experience by reducing the
number of commands needed to manage the sidebar.
```
