return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
    opts = {
      -- These are Mason *package* names
      ensure_installed = {
        -- Lua
        "stylua",

        -- Python
        "ruff",     -- we’ll use ruff_format in Conform
        "pyright",  -- LSP server

        -- TypeScript / JS
        "prettier",
        "typescript-language-server",
      },
      auto_update = false,
      run_on_start = true,
      start_delay = 3000, -- ms; gives Mason time to init
      debounce_hours = 12,
    },
  },
}
