-- Git integration for buffers
return {
	"lewis6991/gitsigns.nvim",
	opts = {
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 100,
		},
	},
}
