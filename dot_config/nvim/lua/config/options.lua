-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- snacks.image detects the terminal with an XTVERSION query and gives up after
-- 1s. Tell it outright when we are directly in Ghostty (never through a mux).
if vim.env.TERM_PROGRAM == "ghostty" and not vim.env.ZELLIJ and not vim.env.TMUX then
  vim.env.SNACKS_GHOSTTY = "1"
end

-- mermaid-cli's headless Chrome lives outside ~/.cache (mole wipes ~/.cache).
vim.env.PUPPETEER_CACHE_DIR = vim.env.PUPPETEER_CACHE_DIR or (vim.env.HOME .. "/.local/share/puppeteer")
