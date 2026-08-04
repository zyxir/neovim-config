return {
  {
    "coder/claudecode.nvim",
    opts = {
      terminal_cmd = "claude --permission-mode auto",
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
