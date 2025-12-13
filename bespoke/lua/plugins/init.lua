return {
	-- Theme
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },

	-- WhichKey
	{ "folke/which-key.nvim", event = "VeryLazy", opts = {} },

	-- Icons
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- UI
	{ import = "plugins.ui" },
	{ import = "plugins.snacks" },

	-- Pretty Markdown
	{ import = "plugins.markdown" },

	-- Finder
	{ import = "plugins.fzf" },

	-- Explorer
	{ import = "plugins.explorer" },

	-- Treesitter
	{ import = "plugins.treesitter" },

	-- MasonTools
	{ import = "plugins.mason_tools" },

	-- LSP
	{ import = "plugins.lsp" },
	{ import = "plugins.rename" },

	-- Completion
	{ import = "plugins.completion" },

	-- Format
	{ import = "plugins.format" },

	-- Git
	{ import = "plugins.git" },

	-- Terminal
	{ import = "plugins.terminal" },

	-- Commenting
	{ "numToStr/Comment.nvim", opts = {} },

	-- Rust
	{ import = "plugins.rust" },
}
