return {
  "keaising/im-select.nvim",
  opts = {
    default_im_select = "com.apple.keylayout.USExtended", -- English
    default_command = "macism", -- macOS IM switcher
    set_default_events = { "InsertLeave", "CmdlineLeave" },
    set_previous_events = {}, -- disable restore-previous behavior
    async_switch_im = true,
  },
  cond = vim.fn.has("mac") == 1, -- macOS only
  config = function(_, opts)
    require("im_select").setup(opts)
    -- Always switch to Squirrel (Rime) when entering insert mode
    vim.api.nvim_create_autocmd("InsertEnter", {
      callback = function()
        vim.fn.jobstart({ "macism", "im.rime.inputmethod.Squirrel.Hans" })
      end,
    })
    -- Restore English on focus gain, but only if in normal mode (not insert)
    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function()
        if vim.api.nvim_get_mode().mode == "n" then
          vim.fn.jobstart({ "macism", "com.apple.keylayout.USExtended" })
        end
      end,
    })
  end,
}
