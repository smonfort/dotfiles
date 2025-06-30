-- markdown preview plugin for (neo)vim
return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
	config = function()
		vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", { desc = "Markdown preview" })
		vim.g.mkdp_preview_options = {
			uml = { server = "https://plantuml.cacd2.io" },
		}
	end,
}
