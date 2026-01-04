local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

-- Resize splits when terminal size changes
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  command = "tabdo wincmd =",
})

vim.api.nvim_create_autocmd("DirChanged", {
  group = augroup,
  callback = function()
    if type(vim.g.dap_load_project) == "function" then
      vim.g.dap_load_project()
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup,
  pattern = "*/.nvim/dap.lua",
  callback = function()
    if type(vim.g.dap_load_project) == "function" then
      vim.g.dap_load_project()
    end
  end,
})
