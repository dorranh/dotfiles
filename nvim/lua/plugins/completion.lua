return {
	{
		"saghen/blink.cmp",
		dependencies = {
			"L3MON4D3/LuaSnip", -- snippet engine
		},
		event = "InsertEnter",
		opts = function()
			local minuet = require("minuet")

			return {
				-- Make sure these are enabled; this is the usual baseline.
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
					providers = {
						minuet = {
							name = "minuet",
							module = "minuet.blink",
							async = true,
							-- Should match minuet.config.request_timeout * 1000,
							-- since minuet.config.request_timeout is in seconds
							timeout_ms = 3000,
							score_offset = 50, -- Gives minuet higher priority among suggestions
						},
					},
				},

				-- You can choose auto popup or manual (Ctrl-Space).
				completion = {
					trigger = {
						prefetch_on_insert = false, -- Disabled according to minuet docs. Might want to re-enable.
						show_on_insert = true, -- set false if you only want manual trigger
					},
				},

				keymap = {
					preset = "default",

					["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
					["<CR>"] = { "accept", "fallback" },

					["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
					["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },

					-- Minuet LLM completion integration (manually triggered)
					["<A-y>"] = minuet.make_blink_map(),
				},
			}
		end,
	},
}
