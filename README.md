# Neovim Config

Personal Neovim configuration built on [LazyVim](https://github.com/LazyVim/LazyVim).

## Install

```bash
# macOS / Linux
git clone https://github.com/zyxir/neovim-config.git ~/.config/nvim

# Windows
git clone https://github.com/zyxir/neovim-config.git %LOCALAPPDATA%\nvim
```

First launch auto-bootstraps lazy.nvim and installs all plugins. Language servers, formatters, and debuggers are installed automatically by Mason — no manual setup.

### Prerequisites

| Dependency | Why | macOS | Windows |
|---|---|---|---|
| Neovim ≥ 0.10 | Required by multicursor, snacks | `brew install neovim` | `winget install Neovim.Neovim` |
| Git | Clone repo + plugin management | built-in (`xcode-select --install`) | `winget install Git.Git` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Search engine for telescope, grug-far | `brew install ripgrep` | `winget install BurntSushi.ripgrep.MSVC` |
| [Nerd Font](https://www.nerdfonts.com) | Icons in UI (bufferline, lualine, etc.) | [JetBrainsMonoNL Nerd Font Propo](https://github.com/ryanoasis/nerd-fonts/releases) | same |
| C compiler | Compile treesitter parsers | — | `winget install BrechtSanders.WinLibs.POSIX.UCRT`¹ |
| [macism](https://github.com/laishulu/macism) | IM auto-switching (macOS only) | `brew tap laishulu/homebrew && brew install macism` | — |

## Keybindings

| Key | Action |
|---|---|
| `g/` | Rip-substitute (interactive find & replace) |
| `<leader>m` prefix | Multi-cursor (`mn` match, `mq` toggle, `Esc` clear) |
| `Ctrl-LeftClick` | Add cursor under mouse |

## Additions

- **`multicursor.nvim`** — multiple cursors with mouse support
- **`rip-substitute`** — minimalist interactive find & replace at `g/`
- **`im-select.nvim`** — auto-switch IM (Squirrel ↔ English) on mode change (macOS)
- **Snacks explorer** — shows hidden and git-ignored files by default
- **Colorscheme**: Catppuccin
- **Font**: JetBrainsMonoNL Nerd Font Propo (no ligatures)
- **Python**: basedpyright instead of pyright
- **Scala**, **DAP**, **Claude Code** extras enabled

¹ LLVM's `clang` targets MSVC on Windows and cannot compile without Visual Studio Build Tools. WinLibs bundles a self-contained GCC that works out of the box.
