vim.pack.add({
	gh("folke/snacks.nvim"),
})

require("snacks").setup({
	input = { enabled = true },
})
