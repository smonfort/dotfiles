vim.pack.add({
	gh("mason-org/mason.nvim"),
	gh("neovim/nvim-lspconfig"),
	gh("mason-org/mason-lspconfig.nvim"),
	gh("https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim"),
})

require("mason").setup({})
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"ts_ls",
	},
})
