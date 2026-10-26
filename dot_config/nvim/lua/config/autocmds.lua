-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Agent hygiene: agents edit files from other panes. Reload buffers so a
-- :w never clobbers their edit. LazyVim already runs checktime on focus;
-- this adds a timer (for tmux panes that never change nvim's focus) and a
-- loud notice when a reload happens.
vim.o.autoread = true
local timer = vim.uv.new_timer()
timer:start(2000, 2000, vim.schedule_wrap(function()
  if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
    vim.cmd("silent! checktime")
  end
end))
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = vim.api.nvim_create_augroup("agent_reload", { clear = true }),
  callback = function(ev)
    vim.notify("Reloaded from disk: " .. vim.fn.fnamemodify(ev.file, ":~:."), vim.log.levels.WARN)
  end,
})
