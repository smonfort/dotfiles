return {
	"voldikss/vim-floaterm",
	config = function()
		vim.g.floaterm_titleposition = "center"
		vim.g.floaterm_title = " 😍 Terminal "
		vim.g.floaterm_height = 0.8
		vim.g.floaterm_width = 0.8
	end,
	keys = {
		{ "<leader>t", "<cmd>FloatermToggle<cr>", desc = "Toggle float term" },
	},
}
