vim.pack.add({
	gh("kdheepak/lazygit.nvim"),
})

vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "Open LazyGit" })
vim.keymap.set("n", "<leader>lG", "<cmd>LazyGitCurrentFile<cr>", { desc = "Open LazyGit for the current file" })
