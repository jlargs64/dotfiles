-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Ensure Go binary is in PATH for neotest-golang
vim.env.PATH = vim.env.PATH .. ":/opt/homebrew/bin:" .. vim.fn.expand("$HOME") .. "/go/bin"

-- Set GOPATH explicitly to help neotest-golang find Go workspace
vim.env.GOPATH = vim.fn.expand("$HOME") .. "/go"

-- Fix case sensitivity issue for Go projects
-- Resolve to canonical (lowercase) path to match what 'go list' returns
local cwd = vim.fn.getcwd()
if cwd:match("/GitHub/") then
  local canonical_path = cwd:gsub("/GitHub/", "/github/")
  vim.cmd("cd " .. vim.fn.fnameescape(canonical_path))
end
