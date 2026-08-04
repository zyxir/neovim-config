return {
  {
    "coder/claudecode.nvim",
    opts = {
      keep_terminal_focus = true,
      terminal = {
        provider = "snacks",
        snacks_win_opts = {
          position = "bottom",
          height = 0.40,
        },
      },
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    },
  },
}
