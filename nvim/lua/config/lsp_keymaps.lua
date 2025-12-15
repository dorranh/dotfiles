local M = {}

function M.on_attach(args)
	local bufnr = args.buf
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
	end

	-- Remove Neovim's default LSP hover mapping, if present
	pcall(vim.keymap.del, "n", "K", { buffer = bufnr })

	-- Set ours on the next tick so it wins even if defaults run after us
	vim.schedule(function()
		vim.keymap.set("n", "K", function()
			require("utils.lsp").hover_filtered()
		end, { buffer = bufnr, desc = "Hover (filtered LSP)" })
	end)

	-- ── Core navigation (NVChad-style, <leader>-prefixed) ──────────
	map("n", "<leader>gd", vim.lsp.buf.definition, "LSP go to definition")
	map("n", "<leader>gD", vim.lsp.buf.declaration, "LSP go to declaration")
	map("n", "<leader>gi", vim.lsp.buf.implementation, "LSP go to implementation")
	map("n", "<leader>gy", vim.lsp.buf.type_definition, "LSP go to type definition")

	-- References (picker if available)
	map("n", "<leader>gr", function()
		local ok, fzf = pcall(require, "fzf-lua")
		if ok then
			fzf.lsp_references()
		else
			vim.lsp.buf.references()
		end
	end, "LSP references")

	-- ── Symbols ────────────────────────────────────────────────────
	map("n", "<leader>ls", function()
		local ok, fzf = pcall(require, "fzf-lua")
		if ok then
			fzf.lsp_document_symbols()
		else
			vim.lsp.buf.document_symbol()
		end
	end, "LSP document symbols")

	map("n", "<leader>lS", function()
		local ok, fzf = pcall(require, "fzf-lua")
		if ok then
			fzf.lsp_workspace_symbols()
		else
			vim.lsp.buf.workspace_symbol("")
		end
	end, "LSP workspace symbols")

	-- ── Info / actions ─────────────────────────────────────────────
	map("n", "<C-k>", vim.lsp.buf.signature_help, "LSP signature help")
	map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP code action")

	-- Rename (avoid collision with your <leader>rn number toggle)
	vim.keymap.set("n", "<leader>rn", function()
		require("inc_rename")
		return ":IncRename " .. vim.fn.expand("<cword>")
	end, { expr = true, desc = "Rename symbol" })

	-- ── Diagnostics ────────────────────────────────────────────────
	map("n", "[d", vim.diagnostic.goto_prev, "diagnostic prev")
	map("n", "]d", vim.diagnostic.goto_next, "diagnostic next")
	map("n", "<leader>dd", vim.diagnostic.open_float, "diagnostic float")
end

function M.setup()
	local grp = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true })
	vim.api.nvim_create_autocmd("LspAttach", {
		group = grp,
		callback = function(args)
			M.on_attach(args)
		end,
	})
end

return M
