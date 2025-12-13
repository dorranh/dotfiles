local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.mouse = "a"

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.splitright = true
opt.splitbelow = true

opt.updatetime = 200
opt.timeoutlen = 400

opt.clipboard = "unnamedplus"

-- Ensure filetype detection + filetype plugins/indent are enabled
vim.cmd.filetype("plugin indent on")
