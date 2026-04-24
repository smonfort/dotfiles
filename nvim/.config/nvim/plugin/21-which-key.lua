vim.pack.add({
	gh("folke/which-key.nvim"),
})

require("which-key").setup({})

vim.keymap.set("n", "<leader>?", "<cmd>lua require('which-key').show()<cr>", { desc = "Show keymaps" })
