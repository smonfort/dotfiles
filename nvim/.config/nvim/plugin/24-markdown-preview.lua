-- Build hook must be registered before vim.pack.add() to catch the install event
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "markdown-preview.nvim" and (ev.data.kind == "install" or ev.data.kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("markdown-preview.nvim")
			end
			vim.fn["mkdp#util#install"]()
		end
	end,
})

vim.pack.add({
	gh("iamcco/markdown-preview.nvim"),
})

vim.g.mkdp_browser = "firefox"

vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle markdown preview" })
