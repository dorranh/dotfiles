return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      view = { width = 35 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
      git = { enable = true },
    },
  },
}

