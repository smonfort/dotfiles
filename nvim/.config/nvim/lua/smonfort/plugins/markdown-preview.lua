-- markdown preview plugin for (neo)vim
return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = "cd app && yarn install",
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
	end,
	config = function()
		vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", { desc = "Markdown preview" })
		vim.g.mkdp_preview_options = {
			uml = { server = "https://plantuml.cacd2.io" },
		}
	end,
}
