
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      -- Add end-of-line / whitespace cleanup everywhere
      formatters_by_ft = {
        ["*"] = { "trim_whitespace", "trim_newlines" },

        lua = { "stylua" },

        -- Python: ruff does both formatting + (optionally) fixes
        python = { "ruff_format" },

        -- Rust: uses rustfmt from your toolchain (rustup is typical)
        rust = { "rustfmt" },

        -- TypeScript / JS
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },

        -- Handy extras since prettier is already around
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      },

      format_on_save = function(bufnr)
        -- Avoid formatting gigantic files accidentally
        local max = 2000 * 1024 -- 2MB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > max then
          return
        end
        return { lsp_fallback = true, timeout_ms = 3000 }
      end,
    },
  },
}

