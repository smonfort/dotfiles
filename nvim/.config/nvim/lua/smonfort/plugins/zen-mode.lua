return {
	"folke/zen-mode.nvim",
	dependencies = {
		"folke/twilight.nvim",
	},
	config = function()
		vim.keymap.set("n", "<leader>zm", "<cmd>:ZenMode<cr>", { desc = "Toogle Zen mode" })
		-- Pending issue with tmux status bar : https://github.com/folke/zen-mode.nvim/issues/66
		require("zen-mode").setup({
			window = {
				width = 0.85,
			},
			on_open = function(_)
				vim.fn.system([[tmux set status off]])
			end,
			on_close = function(_)
				vim.fn.system([[tmux set status on]])
			end,
			twilight = { enabled = true },
			plugins = {
				wezterm = {
					enabled = true,
					font = "+4",
				},
			},
		})
	end,
}
