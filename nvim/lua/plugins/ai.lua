return {
	-- Minuet provides LLM-powered completions
	{
		"milanglacier/minuet-ai.nvim",
		config = function()
			require("minuet").setup({
				provider = "openai_compatible",
				provider_options = {
					openai_compatible = {
						-- Ollama local API
						end_point = "http://localhost:11434/v1/chat/completions",
						-- A dummy or placeholder API key required by the plugin (Ollama doesn’t enforce it)
						api_key = "TERM",
						-- Model name defined in Ollama
						model = "gemma3:12b",
						-- Optional parameters passed to the model
						optional = {
							max_tokens = 1024,
							temperature = 0.2,
						},
					},
				},
			})
		end,
	},
	{ "nvim-lua/plenary.nvim" },
}
