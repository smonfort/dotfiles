vim.pack.add({
	gh("folke/trouble.nvim"),
})

require("trouble").setup({})

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle diagnostocs" })
