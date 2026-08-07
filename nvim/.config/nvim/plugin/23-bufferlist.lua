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

-- Bufferlist draws the buffer numbers via the native number column, styled by LineNr.
-- Scope a bolder highlight to just this window so it doesn't affect LineNr elsewhere.
vim.api.nvim_set_hl(0, "BufferListLineNr", { fg = "#ff9e64", bold = true })

vim.keymap.set("n", "<leader>b", function()
	vim.cmd("BufferList")
	vim.wo[0].winhighlight = "LineNr:BufferListLineNr"
end, { desc = "Open bufferlist" })
