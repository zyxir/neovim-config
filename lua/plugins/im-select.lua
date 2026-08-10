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

    local group = vim.api.nvim_create_augroup("user_im_select", { clear = true })

    -- Restore English on focus gain, but only if in normal mode (not insert)
    vim.api.nvim_create_autocmd("FocusGained", {
      group = group,
      callback = function()
        if vim.api.nvim_get_mode().mode == "n" then
          vim.fn.jobstart({ "macism", "com.apple.keylayout.USExtended" })
        end
      end,
    })

    -- Toggle IM switching on/off
    vim.api.nvim_create_user_command("IMSelectToggle", function()
      if vim.b.im_select_disabled then
        vim.b.im_select_disabled = false
        vim.notify("IM switching: ON", vim.log.levels.INFO)
      else
        vim.b.im_select_disabled = true
        -- Immediately switch to English
        vim.fn.jobstart({ "macism", "com.apple.keylayout.USExtended" })
        vim.notify("IM switching: OFF (US keyboard)", vim.log.levels.INFO)
      end
    end, {})

    -- Wrap the InsertEnter callback to respect the toggle
    vim.api.nvim_create_autocmd("InsertEnter", {
      group = group,
      callback = function()
        if not vim.b.im_select_disabled then
          vim.fn.jobstart({ "macism", "im.rime.inputmethod.Squirrel.Hans" })
        end
      end,
    })
  end,
}
