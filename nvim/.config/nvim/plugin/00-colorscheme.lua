vim.pack.add({
	gh("folke/tokyonight.nvim"),
})

require("tokyonight").setup({
	style = "night",
	-- Change the background
	on_colors = function(colors)
		colors.bg = "#000000"
		colors.bg_statusline = "#000000"
	end,
})
vim.cmd([[colorscheme tokyonight]])
