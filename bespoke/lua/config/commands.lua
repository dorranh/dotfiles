vim.api.nvim_create_user_command("Cheatsheet", function()
	require("cheatsheet").open()
end, {})

vim.api.nvim_create_user_command("CheatsheetSearch", function()
	require("cheatsheet").search()
end, {})
