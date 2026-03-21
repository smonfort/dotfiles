-- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim.
return {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		ensure_installed = {
			"html",
			"cssls",
			"tailwindcss",
			"astro",
			"graphql",
			"emmet_ls",
			"terraformls",
			"marksman",
			"ts_ls",
			"rust_analyzer",
			"dockerls",
			"ltex",
		},
	},
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
	},
}
