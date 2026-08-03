return {
  {
    "coder/claudecode.nvim",
    opts = {
      terminal = {
        terminal_cmd = "claude --permission-mode auto",
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
