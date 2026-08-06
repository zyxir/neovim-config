return {
  "mg979/vim-visual-multi",
  keys = {
    { "<C-n>", mode = "n", desc = "Multi-cursor: select word" },
  },
  init = function()
    vim.g.VM_default_mappings = 1
  end,
}
