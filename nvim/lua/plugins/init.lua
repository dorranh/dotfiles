return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "css",
        "html",
        "lua",
        "python",
        "rust",
        "scala",
        "sql",
        "terraform",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
  },

  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    cond = vim.env.NVIM_DISABLE_COPILOT ~= "TRUE",
    config = function()
      require("copilot").setup {}
      vim.g.copilot_no_tab_map = true
    end,
  },
}
