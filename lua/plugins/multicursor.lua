return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    local set = vim.keymap.set

    -- Add cursor above/below
    set({ "n", "x" }, "<M-up>", function() mc.lineAddCursor(-1) end)
    set({ "n", "x" }, "<M-down>", function() mc.lineAddCursor(1) end)

    -- Match word/selection forward/backward
    set({ "n", "x" }, "<leader>mn", function() mc.matchAddCursor(1) end)
    set({ "n", "x" }, "<leader>mN", function() mc.matchAddCursor(-1) end)
    set({ "n", "x" }, "<leader>ms", function() mc.matchSkipCursor(1) end)
    set({ "n", "x" }, "<leader>mS", function() mc.matchSkipCursor(-1) end)

    -- Add/remove cursors with Ctrl+LeftClick
    set("n", "<c-leftmouse>", mc.handleMouse)

    -- Toggle cursors on/off
    set({ "n", "x" }, "<leader>mq", mc.toggleCursor)

    -- Keymap layer: only active when multiple cursors exist
    mc.addKeymapLayer(function(layerSet)
      layerSet({ "n", "x" }, "<left>", mc.prevCursor)
      layerSet({ "n", "x" }, "<right>", mc.nextCursor)
      layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)
      layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)
  end,
}
