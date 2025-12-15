local M = {}

-- LSP clients that should never be used for hover
M.hover_blacklist = {
	ruff = true,
	-- add more here later
}

local function client_allowed_for_hover(client)
	return client
		and not M.hover_blacklist[client.name]
		and client.supports_method
		and client:supports_method("textDocument/hover")
end

local function open_hover(result)
	if not result or not result.contents then
		return false
	end

	local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
	lines = vim.tbl_filter(function(line)
		return line ~= nil and line ~= ""
	end, lines or {})
	if not lines or #lines == 0 then
		return false
	end

	vim.lsp.util.open_floating_preview(lines, "markdown", { border = "rounded" })
	return true
end

function M.hover_filtered(opts)
	opts = opts or {}
	local bufnr = opts.bufnr or 0

	local params = vim.lsp.util.make_position_params(0, "utf-16")
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	for _, client in ipairs(clients) do
		if client_allowed_for_hover(client) then
			-- Request hover from THIS client only (no global notify path)
			client:request("textDocument/hover", params, function(err, result)
				if err then
					-- don’t notify; just fall back
					vim.schedule(function()
						vim.diagnostic.open_float(nil, { focus = false })
					end)
					return
				end

				vim.schedule(function()
					if not open_hover(result) then
						vim.diagnostic.open_float(nil, { focus = false })
					end
				end)
			end, bufnr)

			return
		end
	end

	-- No allowed hover provider attached
	vim.diagnostic.open_float(nil, { focus = false })
end

return M
