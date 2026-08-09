-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Python: use basedpyright instead of pyright for the LSP
-- Must be set before the Python extra loads (lua/plugins/python.lua)
vim.g.lazyvim_python_lsp = "basedpyright"

-- Format on save (global). Toggle with <leader>uf
vim.g.autoformat = true

-- GUI font (Neovide)
-- Use PowerShell instead of cmd.exe for the built-in terminal on Windows
if vim.fn.has("win32") == 1 then
  vim.o.guifont = "JetBrainsMonoNL NFM:h12"
  vim.o.shell = "powershell"
else
  vim.o.guifont = "JetBrainsMonoNL Nerd Font Propo:h12"
end


