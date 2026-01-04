vim.api.nvim_create_user_command("Cheatsheet", function()
	require("cheatsheet").open()
end, {})

vim.api.nvim_create_user_command("CheatsheetSearch", function()
	require("cheatsheet").search()
end, {})

local function render_dap_template()
	local last = vim.g.dap_last_config
	if type(last) ~= "table" or type(last.config) ~= "table" then
		return nil
	end
	local ft = last.filetype or "rust"
	local config = last.config
	local body = { "return {", "  configurations = {" }
	local prefix = "    [" .. string.format("%q", ft) .. "] = "
	local inspected = vim.inspect({ config })
	local parts = vim.split(inspected, "\n", { plain = true })
	body[#body + 1] = prefix .. parts[1]
	local indent = string.rep(" ", #prefix)
	for i = 2, #parts do
		body[#body + 1] = indent .. parts[i]
	end
	body[#body + 1] = "  },"
	body[#body + 1] = "}"
	return body
end

vim.api.nvim_create_user_command("DapBootstrap", function()
	local cwd = vim.fn.getcwd()
	local dir = cwd .. "/.nvim"
	local file = dir .. "/dap.lua"
	if vim.fn.filereadable(file) == 1 then
		vim.cmd("edit " .. file)
		return
	end
	vim.fn.mkdir(dir, "p")
	local template = render_dap_template() or {
		"return {",
		"  -- adapters = {},",
		"  -- configurations = {",
		"  --   rust = {",
		"  --     {",
		"  --       name = \"Debug executable (args)\",",
		"  --       type = \"codelldb\",",
		"  --       request = \"launch\",",
		"  --       program = function()",
		"  --         return vim.fn.input(\"Path to executable: \", vim.fn.getcwd() .. \"/target/debug/\", \"file\")",
		"  --       end,",
		"  --       args = { \"--example\", \"value\" },",
		"  --     },",
		"  --   },",
		"  -- },",
		"}",
	}
	vim.fn.writefile(template, file)
	vim.cmd("edit " .. file)
	if type(vim.g.dap_load_project) == "function" then
		vim.g.dap_load_project()
	end
end, {})

vim.api.nvim_create_user_command("DapReloadProject", function()
	if type(vim.g.dap_load_project) == "function" then
		vim.g.dap_load_project()
		vim.notify("Reloaded .nvim/dap.lua", vim.log.levels.INFO)
	else
		vim.notify("DAP project loader not available", vim.log.levels.WARN)
	end
end, {})
