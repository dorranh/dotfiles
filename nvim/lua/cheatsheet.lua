local M = {}

-- ────────────────────────────────────────────────────────────────
-- Helpers
-- ────────────────────────────────────────────────────────────────

local mode_names = {
	n = "Normal",
	i = "Insert",
	v = "Visual",
	x = "Visual",
	t = "Terminal",
	s = "Select",
	o = "Operator-pending",
	c = "Command-line",
}

local function normalize_modes(mode)
	if type(mode) == "string" then
		return { mode }
	end
	return mode
end

local function mode_label(m)
	return mode_names[m] or tostring(m)
end

local function rhs_to_string(rhs)
	if type(rhs) == "string" then
		return rhs
	end
	if type(rhs) == "function" then
		return "<lua function>"
	end
	return tostring(rhs)
end

-- Safe module loader for items
local function get_items(modname)
	local ok, mod = pcall(require, modname)
	if not ok or type(mod) ~= "table" then
		return {}
	end
	if type(mod.items) ~= "table" then
		return {}
	end
	return mod.items
end

-- Collect all keymap sources
local function collect_items()
	local items = {}
	vim.list_extend(items, get_items("config.keymaps"))
	vim.list_extend(items, get_items("config.lsp_keymaps"))
	return items
end

-- ────────────────────────────────────────────────────────────────
-- Cheatsheet content
-- ────────────────────────────────────────────────────────────────

local function build_lines()
	local items = collect_items()

	-- Group by mode
	local groups = {}
	for _, m in ipairs(items) do
		for _, md in ipairs(normalize_modes(m[1])) do
			groups[md] = groups[md] or {}
			table.insert(groups[md], m)
		end
	end

	local lines = {}
	table.insert(lines, "# Keymaps Cheatsheet")
	table.insert(lines, "")
	table.insert(
		lines,
		"_Generated from your config (source of truth: `config/keymaps.lua`, `config/lsp_keymaps.lua`)._"
	)
	table.insert(lines, "")
	table.insert(lines, "Tip: press `s` to search keymaps.")
	table.insert(lines, "")

	local order = { "n", "i", "v", "x", "t", "c", "o", "s" }
	for _, md in ipairs(order) do
		local g = groups[md]
		if g and #g > 0 then
			table.insert(lines, ("## %s (%s)"):format(mode_label(md), md))
			table.insert(lines, "")
			table.insert(lines, "| Key | Action | Description |")
			table.insert(lines, "|---|---|---|")

			table.sort(g, function(a, b)
				return tostring(a[2]) < tostring(b[2])
			end)

			for _, m in ipairs(g) do
				local lhs, rhs, desc = m[2], rhs_to_string(m[3]), m[4] or ""
				table.insert(lines, ("| `%s` | `%s` | %s |"):format(lhs, rhs:gsub("|", "\\|"), desc))
			end
			table.insert(lines, "")
		end
	end

	return lines
end

-- ────────────────────────────────────────────────────────────────
-- Window / buffer helpers
-- ────────────────────────────────────────────────────────────────

local function find_cheatsheet_win_buf()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_is_valid(buf) and vim.b[buf].__is_cheatsheet then
			return win, buf
		end
	end
	return nil, nil
end

local function jump_to_lhs(buf, lhs)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local needle = "| `" .. lhs .. "` |"
	for i, line in ipairs(lines) do
		if line:find(needle, 1, true) then
			vim.api.nvim_win_set_cursor(0, { i, 0 })
			vim.cmd("normal! zz")
			return true
		end
	end
	return false
end

-- ────────────────────────────────────────────────────────────────
-- Public API
-- ────────────────────────────────────────────────────────────────

function M.open()
	local win, buf = find_cheatsheet_win_buf()
	if win and buf then
		vim.api.nvim_set_current_win(win)
		return
	end

	buf = vim.api.nvim_create_buf(false, true)
	vim.b[buf].__is_cheatsheet = true
	vim.api.nvim_buf_set_name(buf, "Cheatsheet.md")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, build_lines())
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "markdown"

	local width = math.floor(vim.o.columns * 0.75)
	local height = math.floor(vim.o.lines * 0.75)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		border = "rounded",
		style = "minimal",
	})

	-- buffer-local search shortcut
	vim.keymap.set("n", "s", function()
		require("cheatsheet").search()
	end, { buffer = buf, desc = "cheatsheet search" })
end

function M.search()
	local ok, fzf = pcall(require, "fzf-lua")
	if not ok then
		vim.notify("fzf-lua not available", vim.log.levels.WARN)
		return
	end

	local items = collect_items()
	local entries = {}
	local meta = {}

	for _, m in ipairs(items) do
		local modes = normalize_modes(m[1])
		local lhs = m[2]
		local desc = m[4] or ""
		local modes_str = table.concat(modes, ",")

		local is_lsp = desc:match("^LSP") or desc:match("^diagnostic")
		local tag = is_lsp and "LSP " or ""

		local label = string.format("%-6s %-18s %s%s", "[" .. modes_str .. "]", lhs, tag, desc)

		table.insert(entries, label)
		meta[label] = { lhs = lhs }
	end

	fzf.fzf_exec(entries, {
		prompt = "Keymaps> ",
		actions = {
			["default"] = function(selected)
				local pick = selected and selected[1]
				if not pick then
					return
				end
				local info = meta[pick]
				if not info then
					return
				end

				M.open()
				local _, buf = find_cheatsheet_win_buf()
				if buf then
					jump_to_lhs(buf, info.lhs)
				end
			end,
		},
	})
end

return M
