return {
  "chrisgrieser/nvim-rip-substitute",
  keys = {
    {
      "<leader>sr",
      function() require("rip-substitute").sub() end,
      mode = { "n", "x" },
      desc = "Rip Substitute",
    },
  },
  opts = {},
}
