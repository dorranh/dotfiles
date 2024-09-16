---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    -- ["<leader>ts"] = {
    --   function()
    --     require("base46").toggle_transparency()
    --   end,
    --   "toggle transparency",
    -- },
  },
}

M.tests = {
  n = {
    ["<leader>tt"] = {
      function()
        -- require("Comment.api").toggle.linewise.current()
        require("neotest").run.run()
      end,
      "Run nearest test",
    },
    ["<leader>tf"] = {
      function()
        -- require("Comment.api").toggle.linewise.current()
        require("neotest").run.run(vim.fn.expand "%")
      end,
      "Run current test file",
    },
    ["<leader>to"] = {
      function()
        require("neotest").output.open { enter = true }
      end,
      "Show test output",
    },
    ["<leader>ts"] = {
      function()
        require("neotest").summary.open()
      end,
      "Show test output",
    },
  },
}
-- more keybinds!

return M
