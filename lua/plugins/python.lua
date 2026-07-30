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
}
