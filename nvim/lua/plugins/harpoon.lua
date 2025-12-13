return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
			},
		},
		keys = function()
			local harpoon = require("harpoon")

			return {
				{
					"<leader>a",
					function()
						harpoon:list():add()
					end,
					desc = "Harpoon add file",
				},
				{
					"<leader>dr",
					function()
						harpoon:list():remove()
					end,
					desc = "Harpoon remove file",
				},
				{
					"<leader>hp",
					function()
						harpoon.ui:toggle_quick_menu(harpoon:list())
					end,
					desc = "Harpoon menu",
				},
				{
					"<leader>1",
					function()
						harpoon:list():select(1)
					end,
					desc = "Harpoon file 1",
				},
				{
					"<leader>2",
					function()
						harpoon:list():select(2)
					end,
					desc = "Harpoon file 2",
				},
				{
					"<leader>3",
					function()
						harpoon:list():select(3)
					end,
					desc = "Harpoon file 3",
				},
				{
					"<leader>4",
					function()
						harpoon:list():select(4)
					end,
					desc = "Harpoon file 4",
				},

				{
					"<leader>H",
					function()
						local harpoon = require("harpoon")
						local list = harpoon:list()

						local files = {}
						for i, item in ipairs(list.items) do
							table.insert(files, string.format("%d: %s", i, item.value))
						end

						require("fzf-lua").fzf_exec(files, {
							prompt = "Harpoon> ",
							actions = {
								["default"] = function(selected)
									if not selected then
										return
									end
									local index = tonumber(selected[1]:match("^(%d+):"))
									if index then
										list:select(index)
									end
								end,
							},
						})
					end,
					desc = "Harpoon picker",
				},
			}
		end,
	},
}
