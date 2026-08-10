return {
  -- Override nvim-metals keymaps: the LazyVim Scala extra hardcodes telescope
  -- which isn't installed (LazyVim uses snacks.nvim). The original keymaps are
  -- preserved below alongside new test-running shortcuts.
  {
    "scalameta/nvim-metals",
    ft = { "scala", "sbt", "java" },
    keys = {
      -- (original) Show metals commands — fixed to use native vim.ui.select
      {
        "<leader>me",
        function()
          local metals = require("metals")
          local commands = require("metals.commands").commands_table

          vim.ui.select(commands, {
            prompt = "Metals commands:",
            format_item = function(cmd)
              return string.format("%s  (%s)", cmd.label, cmd.hint)
            end,
          }, function(selection)
            if selection then
              metals[selection.id]()
            end
          end)
        end,
        desc = "Metals commands",
      },
      -- (original) Compile cascade
      {
        "<leader>mc",
        function()
          require("metals").compile_cascade()
        end,
        desc = "Metals compile cascade",
      },
      -- (original) Hover worksheet
      {
        "<leader>mh",
        function()
          require("metals").hover_worksheet()
        end,
        desc = "Metals hover worksheet",
      },
      -- (new) Import build
      {
        "<leader>mi",
        function()
          require("metals").import_build()
        end,
        desc = "Metals import build",
      },
      -- (new) Run current test file via persistent sbt terminal
      {
        "<leader>mt",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 100, false)

          local pkg = ""
          local cls = ""

          for _, line in ipairs(lines) do
            local p = line:match("^package%s+([%w%.]+)")
            if p then
              pkg = p
            end
            local c = line:match("^class%s+(%w+)")
              or line:match("^object%s+(%w+)")
              or line:match("^trait%s+(%w+)")
            if c and cls == "" then
              cls = c
            end
          end

          if cls == "" then
            vim.notify("Could not determine class name from file", vim.log.levels.ERROR)
            return
          end

          local fqcn = pkg ~= "" and (pkg .. "." .. cls) or cls
          require("utils.sbt").send("testOnly " .. fqcn)
        end,
        desc = "Run test file via sbt",
      },
      -- (new) Debug current file via DAP runOrTestFile
      {
        "<leader>mr",
        function()
          local dap = require("dap")
          dap.run({
            type = "scala",
            request = "launch",
            name = "RunOrTest",
            metals = {
              runType = "runOrTestFile",
            },
          })
        end,
        desc = "DAP debug current file",
      },
      -- (new) Debug: select test suite via DAP
      {
        "<leader>mT",
        function()
          require("metals").select_test_suite()
        end,
        desc = "DAP select test suite",
      },
    },
  },
}
