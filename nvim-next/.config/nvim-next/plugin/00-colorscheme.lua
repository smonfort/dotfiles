vim.pack.add({
	gh("folke/tokyonight.nvim"),
})

require("tokyonight").setup({
	style = "night",
})
vim.cmd([[colorscheme tokyonight]])
