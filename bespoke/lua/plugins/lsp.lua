return {
	-- lspconfig provides server defaults (cmd, filetypes, root_dir, etc.)
	-- We are NOT using lspconfig.setup(), only its registrations.
	{
		"neovim/nvim-lspconfig",
		lazy = false, -- ensure defaults are registered before vim.lsp.enable()
	},

	-- Mason: installs LSP server binaries and adds mason/bin to PATH
	{ "williamboman/mason.nvim", cmd = "Mason", opts = {} },

	-- Mason-lspconfig: ensures servers are installed (install-only role here)
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			ensure_installed = {
				"lua_ls",
				"pyright",
				"ts_ls",
				-- rust_analyzer intentionally omitted (rustaceanvim manages Rust)
			},
			automatic_installation = true,
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)

			-- Completion capabilities (blink.cmp)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, blink = pcall(require, "blink.cmp")
			if ok and blink.get_lsp_capabilities then
				capabilities = blink.get_lsp_capabilities(capabilities)
			end

			-- Override / extend server configs (lspconfig supplies the base defaults)
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			})

			vim.lsp.config("pyright", {
				capabilities = capabilities,
			})

			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
			})

			-- Enable servers so they attach automatically by filetype
			vim.lsp.enable({ "lua_ls", "pyright", "ts_ls" })
		end,
	},
}
