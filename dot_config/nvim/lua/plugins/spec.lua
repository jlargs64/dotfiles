-- Spec-driven workflow: read specs in-buffer, review agent diffs, edit the FS.
-- lang.markdown + editor.aerial extras live in lazyvim.json (:LazyExtras).
return {
  -- Review what the agents did: side-by-side, file-by-file.
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview (working tree)" },
      { "<leader>gV", "<cmd>DiffviewOpen main...HEAD<cr>", desc = "Diffview (branch vs main)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview file history" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
    },
    opts = { enhanced_diff_hl = true },
  },

  -- Edit the filesystem like a buffer (explorer stays for the overview).
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = { { "-", "<cmd>Oil<cr>", desc = "Oil (parent dir)" } },
    opts = { view_options = { show_hidden = true }, skip_confirm_for_simple_edits = true },
  },

  -- Explorer pinned left; inline images + mermaid (needs kitty graphics: Ghostty ok).
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { replace_netrw = false }, -- oil owns `-`/netrw
      image = { enabled = true, doc = { enabled = true, inline = true, float = true } },
    },
  },

  -- Specs: render checkboxes/callouts too (the extra turns checkboxes off).
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = { checkbox = { enabled = true }, heading = { icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " } } },
  },
}
