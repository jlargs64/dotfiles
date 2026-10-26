return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.sql = { "sqlfluff" }
    opts.formatters_by_ft.markdown = { "prettier" }

    opts.formatters = opts.formatters or {}
    opts.formatters.prettier = {
      prepend_args = { "--prose-wrap", "always", "--print-width", "80" },
    }
    -- sqlfluff installed via `uv tool install sqlfluff`
    opts.formatters.sqlfluff = {
      command = vim.fn.expand("~/.local/bin/sqlfluff"),
      args = { "fix", "--dialect", "postgres", "-" },
      stdin = true,
    }
  end,
}
