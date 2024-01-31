local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "m4xshen/smartcolumn.nvim",
    event = { "InsertEnter" },
    opts = {
      colorcolumn = "100",
      disabled_filetypes = {
        "nvdash",
        "help",
      },
    },
  },

  -- begin metals
  {
    "scalameta/nvim-metals",
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
    ft = { "scala", "sbt" },
    event = "BufEnter *.worksheet.sc",
    config = function()
      local api = vim.api
      ----------------------------------
      -- OPTIONS -----------------------
      ----------------------------------
      -- global
      vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }
      vim.opt_global.shortmess:remove "F"
      vim.opt_global.shortmess:append "c"
      -- LSP Setup ---------------------
      ----------------------------------
      local metals_config = require("metals").bare_config()

      -- Example of settings
      metals_config.settings = {
        showImplicitArguments = true,
        showInferredType = true,
        superMethodLensesEnabled = true,
        showImplicitConversionsAndClasses = true,
      }

      -- *READ THIS*
      -- I *highly* recommend setting statusBarProvider to true, however if you do,
      -- you *have* to have a setting to display this in your statusline or else
      -- you'll not see any messages from metals. There is more info in the help
      -- docs about this
      metals_config.init_options.statusBarProvider = "on"

      -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Debug settings if you're using nvim-dap
      local dap = require "dap"

      dap.configurations.scala = {
        {
          type = "scala",
          request = "launch",
          name = "RunOrTest",
          metals = {
            runType = "runOrTestFile",
            --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
          },
        },
        {
          type = "scala",
          request = "launch",
          name = "Test Target",
          metals = {
            runType = "testTarget",
          },
        },
      }

      metals_config.on_attach = function(client, bufnr)
        local metals = require "metals"
        local utils = require "core.utils"
        utils.load_mappings("lspconfig", { buffer = bufnr })
        metals.setup_dap()

        local wk = require "which-key"
        wk.register({
          ["<localleader>"] = {
            h = {
              name = "hover",
              c = {
                function()
                  metals.toggle_setting "showImplicitConversionsAndClasses"
                end,
                "Toggle show implicit conversions and classes",
              },
              i = {
                function()
                  metals.toggle_setting "showImplicitArguments"
                end,
                "Toggle show implicit arguments",
              },
              t = {
                function()
                  metals.toggle_setting "showInferredType"
                end,
                "Toggle show inferred type",
              },
            },
            t = {
              name = "Tree view",
              t = {
                function()
                  require("metals.tvp").toggle_tree_view()
                end,
                "Toggle tree view",
              },
              r = {
                function()
                  require("metals.tvp").reveal_in_tree()
                end,
                "Review in tree view",
              },
            },
            w = {
              function()
                metals.hover_worksheet { border = "single" }
              end,
              "Hover worksheet",
            },
          },
        }, {
          buffer = bufnr,
        })
        wk.register({
          ["<localleader>t"] = {
            function()
              metals.type_of_range()
            end,
            "Type of range",
          },
        }, {
          mode = "v",
          buffer = bufnr,
        })
      end

      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        -- NOTE: You may or may not want java included here. You will need it if you
        -- want basic Java support but it may also conflict if you are using
        -- something like nvim-jdtls which also works on a java filetype autocmd.
        pattern = { "scala", "sbt", "java" },
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,
  },

  -- end metals
}
-- To make a plugin not be loaded
-- {
--   "NvChad/nvim-colorizer.lua",
--   enabled = false
-- },

-- All NvChad plugins are lazy-loaded by default
-- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
-- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
-- {
--   "mg979/vim-visual-multi",
--   lazy = false,
-- }
--

return plugins
