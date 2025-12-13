local M = {}

local function hour_local()
	return tonumber(os.date("%H"))
end

function M.apply()
	local h = hour_local()

	-- Day vs night split (tweak)
	if h >= 7 and h < 18 then
		vim.cmd.colorscheme("catppuccin-frappe")
	else
		vim.cmd.colorscheme("catppuccin-frappe")
	end
end

function M.setup()
	-- Ensure catppuccin is configured before applying scheme
	local ok, catppuccin = pcall(require, "catppuccin")
	if ok then
		catppuccin.setup({
			flavour = "mocha",
			integrations = {
				gitsigns = true,
				treesitter = true,
				which_key = true,
				fzf = true,
				native_lsp = { enabled = true },
			},
		})
	end

	M.apply()
end

return M
