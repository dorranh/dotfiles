vim.api.nvim_create_user_command("Cheatsheet", function()
	require("cheatsheet").open()
end, {})

vim.api.nvim_create_user_command("CheatsheetSearch", function()
	require("cheatsheet").search()
end, {})

vim.api.nvim_create_user_command("DapBootstrap", function()
	local cwd = vim.fn.getcwd()
	local dir = cwd .. "/.nvim"
	local file = dir .. "/dap.lua"
	if vim.fn.filereadable(file) == 1 then
		vim.cmd("edit " .. file)
		return
	end
	vim.fn.mkdir(dir, "p")
	local template = {
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
end, {})
