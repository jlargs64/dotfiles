return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- Override LazyVim's SQL formatter with sqlfluff
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.sql = { "sqlfluff" }
    opts.formatters_by_ft.markdown = { "prettier" }

    opts.formatters = opts.formatters or {}
    opts.formatters.prettier = {
      prepend_args = { "--prose-wrap", "always", "--print-width", "80" },
    }
    opts.formatters.sqlfluff = {
      command = vim.fn.expand("~/.local/share/mise/installs/python/3.12.12/bin/sqlfluff"),
      args = { "fix", "--force", "-" },
      stdin = true,
    }
  end,
}
