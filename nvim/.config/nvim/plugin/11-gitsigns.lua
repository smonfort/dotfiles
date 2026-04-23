vim.pack.add({
	gh("lewis6991/gitsigns.nvim"),
})

require("gitsigns").setup({
	current_line_blame = true,
	current_line_blame_opts = {
		delay = 100,
	},
})
