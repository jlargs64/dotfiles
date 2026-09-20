-- Keeps every colorscheme the theme system can select permanently installed,
-- independent of which theme is currently active.
--
-- Without this, lazy.nvim only ever sees the plugins declared by the active
-- theme's neovim.lua (symlinked in as theme.lua). That has two bad effects:
--   * lazy-lock.json churns on every theme switch, so the lockfile is never
--     stable in git
--   * the first switch to a theme has to clone its colorscheme plugin
--
-- Declared `lazy = true` here; the active theme's spec re-declares the same
-- repo with lazy = false and priority, and lazy.nvim merges the two.
--
-- Managed by chezmoi. Not a symlink -- see docs/theme-system.md.
return {
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "nvim-mini/mini.base16", version = false, lazy = true },
}
