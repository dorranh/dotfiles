---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<leader>ts"] = {function() require('base46').toggle_transparency() end, "toggle transparency"}
  },
}

-- more keybinds!

return M
