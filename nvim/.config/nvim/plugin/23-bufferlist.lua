vim.pack.add({
	gh("nvim-tree/nvim-web-devicons"),
	gh("EL-MASTOR/bufferlist.nvim"),
})

require("bufferlist").setup({
	show_path = true, -- show the relative path the first time BufferList is opened
	win_keymaps = {
		{
			"<cr>",
			function(opts)
				local curpos = vim.fn.line(".")
				vim.cmd("bwipeout | buffer " .. opts.buffers[curpos])
			end,
			{ desc = "BufferList: switch to buffer under cursor" },
		},
	},
})

vim.keymap.set("n", "<leader>b", "<cmd>BufferList<CR>", { desc = "Open bufferlist" })
