vim.pack.add({
	{ src = "https://github.com/folke/tokyonight.nvim" },
})

require("tokyonight").setup({
	style = night,
})
vim.cmd([[colorscheme tokyonight]])
