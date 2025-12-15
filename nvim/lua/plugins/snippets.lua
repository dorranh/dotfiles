return {
	{
		"L3MON4D3/LuaSnip",
		build = (function()
			-- Optional: only if you have make available
			return "make install_jsregexp"
		end)(),
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
}
