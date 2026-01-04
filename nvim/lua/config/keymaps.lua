local M = {}

-- Each entry: { mode, lhs, rhs, desc, opts? }
M.items = {
	{ "i", "<C-b>", "<ESC>^i", "move beginning of line" },
	{ "i", "<C-e>", "<End>", "move end of line" },
	{ "i", "<C-h>", "<Left>", "move left" },
	{ "i", "<C-l>", "<Right>", "move right" },
	{ "i", "<C-j>", "<Down>", "move down" },
	{ "i", "<C-k>", "<Up>", "move up" },

	{ "n", "<C-h>", "<C-w>h", "switch window left" },
	{ "n", "<C-l>", "<C-w>l", "switch window right" },
	{ "n", "<C-j>", "<C-w>j", "switch window down" },
	{ "n", "<C-k>", "<C-w>k", "switch window up" },

	{ "n", "<Esc>", "<cmd>noh<CR>", "general clear highlights" },
	{ "n", "<C-s>", "<cmd>w<CR>", "general save file" },
	{ "n", "<C-c>", "<cmd>%y+<CR>", "general copy whole file" },

	{ "n", "<leader>n", "<cmd>set nu!<CR>", "toggle line number" },
	{ "n", "<leader>lr", "<cmd>set rnu!<CR>", "toggle relative number" },

	-- Cheatsheet (replaces NvCheatsheet)
	{
		"n",
		"<leader>ch",
		function()
			require("cheatsheet").open()
		end,
		"toggle cheatsheet",
	},

	{
		{ "n", "x" },
		"<leader>fm",
		function()
			require("conform").format({ lsp_fallback = true })
		end,
		"general format file",
	},

	{ "n", "<leader>ds", vim.diagnostic.setloclist, "LSP diagnostic loclist" },

	-- DAP
	{
		"n",
		"<leader>dc",
		function()
			require("dap").continue()
		end,
		"DAP continue",
	},
	{
		"n",
		"<leader>do",
		function()
			require("dap").step_over()
		end,
		"DAP step over",
	},
	{
		"n",
		"<leader>di",
		function()
			require("dap").step_into()
		end,
		"DAP step into",
	},
	{
		"n",
		"<leader>dO",
		function()
			require("dap").step_out()
		end,
		"DAP step out",
	},
	{
		"n",
		"<leader>db",
		function()
			require("dap").toggle_breakpoint()
		end,
		"DAP toggle breakpoint",
	},
	{
		"n",
		"<leader>dB",
		function()
			require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end,
		"DAP conditional breakpoint",
	},
	{
		"n",
		"<leader>dl",
		function()
			require("dap").run_last()
		end,
		"DAP run last",
	},
	{
		"n",
		"<leader>dr",
		function()
			require("dap").repl.open()
		end,
		"DAP REPL",
	},
	{
		"n",
		"<leader>dt",
		function()
			require("dap").terminate()
		end,
		"DAP terminate",
	},
	{
		"n",
		"<leader>du",
		function()
			require("dapui").toggle()
		end,
		"DAP UI toggle",
	},

	-- Buffers (simple NVChad-ish)
	{ "n", "<leader>b", "<cmd>enew<CR>", "buffer new" },
	{ "n", "<tab>", "<cmd>bnext<CR>", "buffer goto next" },
	{ "n", "<S-tab>", "<cmd>bprev<CR>", "buffer goto prev" },
	{ "n", "<leader>x", "<cmd>bdelete<CR>", "buffer close" },

	-- Comment.nvim
	{
		"n",
		"<leader>/",
		function()
			require("Comment.api").toggle.linewise.current()
		end,
		"toggle comment",
	},
	{
		"v",
		"<leader>/",
		function()
			local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
			vim.api.nvim_feedkeys(esc, "nx", false)
			require("Comment.api").toggle.linewise(vim.fn.visualmode())
		end,
		"toggle comment",
	},

	-- nvim-tree
	{ "n", "<C-n>", "<cmd>NvimTreeToggle<CR>", "nvimtree toggle window" },
	{ "n", "<leader>e", "<cmd>NvimTreeFocus<CR>", "nvimtree focus window" },

	-- fzf-lua
	{
		"n",
		"<leader>fw",
		function()
			require("fzf-lua").live_grep()
		end,
		"fzf live grep",
	},
	{
		"n",
		"<leader>fb",
		function()
			require("fzf-lua").buffers({
				sort_lastused = true,
				cwd_only = false,
				no_term_buffers = true,
			})
		end,
		"fzf find buffers",
	},
	{
		"n",
		"<leader>fh",
		function()
			require("fzf-lua").help_tags()
		end,
		"fzf help page",
	},
	{
		"n",
		"<leader>ma",
		function()
			require("fzf-lua").marks()
		end,
		"fzf find marks",
	},
	{
		"n",
		"<leader>fo",
		function()
			require("fzf-lua").oldfiles()
		end,
		"fzf find oldfiles",
	},
	{
		"n",
		"<leader>fz",
		function()
			require("fzf-lua").blines()
		end,
		"fzf find in current buffer",
	},
	{
		"n",
		"<leader>cm",
		function()
			require("fzf-lua").git_commits()
		end,
		"fzf git commits",
	},
	{
		"n",
		"<leader>gt",
		function()
			require("fzf-lua").git_status()
		end,
		"fzf git status",
	},
	{
		"n",
		"<leader>ff",
		function()
			require("fzf-lua").files()
		end,
		"fzf find files",
	},
	{
		"n",
		"<leader>fa",
		function()
			require("fzf-lua").files({ hidden = true, no_ignore = true, follow = true })
		end,
		"fzf find all files",
	},

	-- terminal
	{ "t", "<C-x>", "<C-\\><C-n>", "terminal escape terminal mode" },
	{ "n", "<leader>h", "<cmd>ToggleTerm direction=horizontal<CR>", "terminal new horizontal term" },
	{ "n", "<leader>v", "<cmd>ToggleTerm direction=vertical<CR>", "terminal new vertical term" },
	{ { "n", "t" }, "<A-h>", "<cmd>ToggleTerm direction=horizontal<CR>", "terminal toggleable horizontal term" },
	{ { "n", "t" }, "<A-v>", "<cmd>ToggleTerm direction=vertical<CR>", "terminal toggleable vertical term" },
	{ { "n", "t" }, "<A-i>", "<cmd>ToggleTerm direction=float<CR>", "terminal toggle floating term" },

	-- which-key
	{ "n", "<leader>wK", "<cmd>WhichKey<CR>", "whichkey all keymaps" },
	{
		"n",
		"<leader>wk",
		function()
			vim.cmd("WhichKey " .. vim.fn.input("WhichKey: "))
		end,
		"whichkey query lookup",
	},
}

function M.apply()
	local map = vim.keymap.set
	for _, m in ipairs(M.items) do
		local mode, lhs, rhs, desc, opts = m[1], m[2], m[3], m[4], m[5]
		opts = opts or {}
		opts.desc = desc
		map(mode, lhs, rhs, opts)
	end
end

return M
