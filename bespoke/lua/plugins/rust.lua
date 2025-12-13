return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- keep stable major
    ft = { "rust" },
    -- rustaceanvim is a filetype plugin; no setup required.
    -- But you CAN set vim.g.rustaceanvim here for options.
    init = function()
      vim.g.rustaceanvim = {
        -- Optional: customize rust-analyzer settings
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = { command = "clippy" },
            },
          },
        },
      }
    end,
  },
}

