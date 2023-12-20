local null_ls = require "null-ls"

local b = null_ls.builtins

local sources = {

  -- Prettier
  b.formatting.prettier.with {
    filetypes = {
      "html",
      "markdown",
      "css",
      "json",
      "yaml",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
  },

  -- Lua
  b.formatting.stylua,

  -- cpp
  b.formatting.clang_format,

  -- Python
  b.formatting.black,
  -- b.formatting.isort,
  b.formatting.ruff,

  -- Scala
  b.formatting.scalafmt,

  -- Rust
  b.formatting.rustfmt,

  -- Terraform
  b.formatting.terraform_fmt,

  -- Nix
  b.formatting.alejandra,

  -- Trim trailing whitespace
  b.formatting.trim_whitespace,
}

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup {
  debug = true,
  sources = sources,
  -- Enable formatting on save
  -- See: https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
          -- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
          vim.lsp.buf.format { async = false }
        end,
      })
    end
  end,
}
