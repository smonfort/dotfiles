vim.pack.add({
	gh("mason-org/mason.nvim"),
	gh("mason-org/mason-lspconfig.nvim"),
	gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
})

require("mason").setup({})
require("mason-lspconfig").setup({
	automatic_enable = false,
})
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"ts_ls",
	},
})
