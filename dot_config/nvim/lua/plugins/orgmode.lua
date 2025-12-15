return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	ft = { "org" },
	config = function()
		require("orgmode").setup({
			org_agenda_files = "~/org/**/*",
			org_default_notes_file = "~/org/inbox.org",
			org_capture_templates = {
				t = {
					description = "Task",
					template = "* TODO %?\n  %u",
					target = "~/org/inbox.org",
				},
				n = {
					description = "Note",
					template = "* %?\n  %u",
					target = "~/org/inbox.org",
				},
				l = {
					description = "TIL",
					template = "* %? %^g\n  %u",
					target = "~/org/til.org",
				},
			},
		})
	end,
}
