# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration based on [LazyVim](https://github.com/LazyVim/LazyVim), a distribution that layers on top of [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management. LazyVim provides sensible defaults for options, keymaps, autocmds, and plugins — all overridable from this repo.

## Architecture

```
init.lua                          # Entry point — bootstraps lazy.nvim, then hands off
lua/config/lazy.lua               # lazy.nvim bootstrap + LazyVim setup
lua/config/options.lua            # Custom vim options + `vim.g` globals (LSP choice, etc.)
lua/config/keymaps.lua            # Custom keymaps (merge on top of LazyVim defaults)
lua/config/autocmds.lua           # Custom autocmds (merge on top of LazyVim defaults)
lua/plugins/                      # Plugin specs — every .lua file here is auto-loaded
lua/plugins/python.lua            # Python development setup
```

### Loading order

1. `init.lua` runs and requires `config.lazy`
2. `lua/config/lazy.lua` self-bootstraps lazy.nvim (clones it if missing), then calls `require("lazy").setup()` with `LazyVim/LazyVim` as the base spec and `lua/plugins/` as the user plugin directory
3. LazyVim's own `config/options.lua`, `config/keymaps.lua`, and `config/autocmds.lua` are loaded first, then the corresponding files in this repo's `lua/config/` are loaded afterward, merging overrides on top

### Plugin patterns

All files under `lua/plugins/` are auto-loaded by lazy.nvim. Each file returns a list of plugin specs. Common patterns (seen in `lua/plugins/example.lua`):

- **Add a plugin**: return `{ "author/plugin.nvim" }`
- **Override LazyVim plugin opts**: return `{ "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } }` or target the specific plugin directly with `{ "author/plugin.nvim", opts = { ... } }`
- **Override opts with a function** (to extend rather than replace lists/tables): `opts = function(_, opts) vim.list_extend(opts.ensure_installed, { "new-parser" }) end`
- **Disable a plugin**: `{ "author/plugin.nvim", enabled = false }`
- **Add LSP server**: extend `neovim/nvim-lspconfig` opts with a new entry in `servers` and add any `dependencies`
- **Add Mason tools**: extend `williamboman/mason.nvim` opts with new entries in `ensure_installed`

### LazyVim extras

LazyVim extras must be imported in `lua/config/lazy.lua` — **not** inside plugin files under `lua/plugins/`. The spec order matters:

```lua
spec = {
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },       -- 1. base
  { import = "lazyvim.plugins.extras.lang.python" },        -- 2. extras
  { import = "plugins" },                                   -- 3. user overrides
}
```

Extras imported from plugin files load too late and trigger a warning. After importing the extra in `lazy.lua`, use a plugin file (e.g. `lua/plugins/python.lua`) only for your overrides on top of it.

## Python development

This config targets Python via the `lazyvim.plugins.extras.lang.python` extra. The following choices are set in `lua/config/options.lua` (must be set before the extra loads):

- **LSP**: `basedpyright` (`vim.g.lazyvim_python_lsp = "basedpyright"`)
- **Formatter/Linter**: `ruff` (the default — `vim.g.lazyvim_python_ruff = "ruff"`)

Mason ensures these are installed along with `debugpy` for DAP debugging. Tree-sitter parsers for Python, `ninja`, and `rst` are included automatically.

### Virtual environments

`venv-selector.nvim` handles venv management:

- **`<leader>cv`** or `:VenvSelect` — open the picker to scan for and select a virtual environment
- The selected venv is cached per project and **auto-activated** on next open
- Activation notifications are enabled (`notify_user_on_venv_activation = true`)

To have a venv be auto-detected on first open, create one in a standard location (`.venv`, `venv`, or any directory picked up by `fd` scanning) and select it once. After that, it activates automatically.

### Testing and debugging

- **Testing**: neotest-python with pytest — use LazyVim's neotest keymaps (`<leader>tt` to run nearest test, etc.)
- **Debugging**: nvim-dap-python — `<leader>dPt` debugs the method under cursor, `<leader>dPc` debugs the class

## Commands

- **Format Lua files**: `stylua .` — configuration in `stylua.toml` (2-space indent, 120 column width)
- **Check for plugin updates**: handled automatically by lazy.nvim (`checker.enabled = true` in `lazy.lua`); use `:Lazy check` in Neovim
- **Sync plugins**: `:Lazy sync` in Neovim

## LSP / Tooling

- **Lua LSP** (lua_ls) is configured via `.neoconf.json` for Neovim API awareness (`neodev` enabled)
- **Formatter**: stylua (installed via Mason, configured via `stylua.toml`)

## lazy.nvim specifics

- `lazyvim.json` tracks the install version and enabled extras — do not edit manually
- Custom plugins default to `lazy = false` (load at startup). LazyVim's own plugins are lazy-loaded by default
- Colorscheme defaults: tries `tokyonight`, falls back to `habamax`
- Plugin versioning is disabled (`version = false`) — always tracks latest git commits
