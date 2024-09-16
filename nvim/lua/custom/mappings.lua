---@type MappingsTable
local M = {}

local is_test_summary_open = false

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
        if is_test_summary_open then
          require("neotest").summary.close()
          is_test_summary_open = false
        else
          require("neotest").summary.open()
          is_test_summary_open = true
        end
      end,
      "Show test summary",
    },
  },
}
-- more keybinds!

return M
