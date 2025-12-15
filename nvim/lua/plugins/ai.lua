return {
	-- Minuet provides LLM-powered completions
	{
		"milanglacier/minuet-ai.nvim",
		config = function()
			require("minuet").setup({
				provider = "gemini",
			})
		end,
	},
	{ "nvim-lua/plenary.nvim" },
}
