vim.pack.add({
	gh("laytan/cloak.nvim"),
})

require("cloak").setup({})

vim.keymap.set("n", "<leader>cc", "<cmd>CloakToggle<cr>", { desc = "Toggle cloak" })
