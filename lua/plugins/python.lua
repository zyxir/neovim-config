return {
  -- Mason: ensure Python tooling is installed
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "basedpyright",
        "ruff",
        "debugpy",
      },
    },
  },

  -- venv selector: notify on activation so it's visible when a cached venv is restored
  {
    "linux-cultist/venv-selector.nvim",
    opts = {
      notify_user_on_venv_activation = true,
    },
  },

  -- basedpyright: use "basic" type checking (like Pylance default) instead
  -- of basedpyright's "recommended" mode which enables all rules.
  -- Modes: off | basic | standard | strict | all | recommended
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
              },
            },
          },
        },
      },
    },
  },

  -- Format on save: ruff format + ruff fix (auto-fixable lint) + organize imports
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        python = {
          "ruff_format",
          "ruff_fix",
          "ruff_organize_imports",
        },
      },
      formatters = {
        ruff_organize_imports = {
          command = "ruff",
          args = { "check", "--fix", "--select", "I", "--stdin-filename", "$FILENAME", "-" },
          stdin = true,
        },
      },
    },
  },
}
