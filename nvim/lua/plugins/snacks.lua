return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			notifier = {
				enabled = true,
				-- Filter out messages that might be interactive prompts
				-- These need the traditional command-line interface
				filter = function(notif)
					-- Skip empty messages
					if not notif.msg or notif.msg == "" then
						return false
					end

					local msg = notif.msg:lower()

					-- Patterns that indicate interactive prompts that need user input
					local interactive_patterns = {
						"swap file", -- Swap file detection dialogs
						"attention", -- Attention prompts (often related to swap files)
						"found a swap file", -- Explicit swap file messages
						"readonly", -- Readonly file prompts
						"[o]pen read%-only", -- Choice prompts
						"[e]dit anyway", -- Choice prompts
						"[r]ecover", -- Choice prompts
						"[d]elete it", -- Choice prompts
						"[q]uit", -- Choice prompts
						"[a]bort", -- Choice prompts
						"(y/n)", -- Yes/no prompts
						"(yes/no)", -- Yes/no prompts
						"press enter", -- Press enter prompts
						"more lines", -- More prompt
						"^e%d+:", -- Error messages that might need interaction (E123: ...)
					}

					-- Check if the message matches any interactive pattern
					for _, pattern in ipairs(interactive_patterns) do
						if msg:find(pattern) then
							return false -- Don't show in notification popup
						end
					end

					-- Allow all other notifications
					return true
				end,
			},
			statuscolumn = { enabled = true },
			scroll = { enabled = true },
			dashboard = {
				enabled = true,
				sections = {
					{ section = "header" },
					{
						pane = 2,
						section = "terminal",
						cmd = "colorscript -e square",
						height = 5,
						padding = 1,
					},
					{ section = "keys", gap = 1, padding = 1 },
					{
						pane = 2,
						icon = " ",
						title = "Recent Files",
						section = "recent_files",
						indent = 2,
						padding = 1,
					},
					{ pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
					{
						pane = 2,
						icon = " ",
						title = "Git Status",
						section = "terminal",
						enabled = function()
							return Snacks.git.get_root() ~= nil
						end,
						cmd = "git status --short --branch --renames",
						height = 5,
						padding = 1,
						ttl = 5 * 60,
						indent = 3,
					},
					{ section = "startup" },
				},
			},
		},
	},
}
