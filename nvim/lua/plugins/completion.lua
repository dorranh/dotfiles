return {
	{
		"saghen/blink.cmp",
		dependencies = {
			"L3MON4D3/LuaSnip", -- snippet engine
		},
		event = "InsertEnter",
		opts = {
			-- Make sure these are enabled; this is the usual baseline.
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},

			-- You can choose auto popup or manual (Ctrl-Space).
			completion = {
				trigger = {
					prefetch_on_insert = true,
					show_on_insert = true, -- set false if you only want manual trigger
				},
			},

			keymap = {
				preset = "default",

				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<CR>"] = { "accept", "fallback" },

				["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
			},
		},
	},
}
