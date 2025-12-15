vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- OPTIONAL - Secrets loading for plugins
-- This currently only supports the MacOS keychain and assumes
-- that some specific secrets are stored there.
require("config.secrets")

-- Core config
require("config.options")
require("config.autocmds")
require("config.commands")
require("config.lsp_keymaps").setup()

-- Plugins
require("lazy").setup({ { import = "plugins" } }, require("config.lazy"))

-- Theme (optional: time-based)
require("theme_by_time_of_day").setup()

-- Mappings last (so plugin mappings/commands exist)
vim.schedule(function()
	require("config.mappings")
end)
