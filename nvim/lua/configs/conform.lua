local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    python = { "ruff" },

    scala = { "scalafmt" },

    rust = { "rustfmt" },

    tf = { "terraform_fmt" },

    css = { "prettier" },
    html = { "prettier" },
    yaml = { "prettier" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    markdown = { "prettier" },

    nix = { "alejandra" },

    ["*"] = { "trim_whitespace" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },

  formatters = {
    prettier = {
      append_args = { "--prose-wrap=always" },
    },
  },
}

return options
