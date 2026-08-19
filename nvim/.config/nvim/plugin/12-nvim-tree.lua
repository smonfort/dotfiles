-- Install plugins using pack
vim.pack.add({
	gh("nvim-tree/nvim-web-devicons"),
	gh("nvim-tree/nvim-tree.lua"),
})

local function on_attach(bufnr)
	local api = require("nvim-tree.api")
	api.config.mappings.default_on_attach(bufnr)
	vim.keymap.set("n", "<Esc>", api.tree.close, { buffer = bufnr, desc = "Close" })
end

require("nvim-tree").setup({
	on_attach = on_attach,
	filters = {
		custom = { "^.git$" },
	},
	renderer = {
		indent_markers = {
			enable = true,
		},
	},
	view = {
		float = {
			enable = true,
			open_win_config = function()
				local screen_w = vim.opt.columns:get()
				local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
				local window_w = screen_w * 0.4
				local window_h = screen_h * 0.7
				local window_w_int = math.floor(window_w)
				local window_h_int = math.floor(window_h)
				local center_x = (screen_w - window_w) / 2
				local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
				return {
					border = "rounded",
					relative = "editor",
					row = center_y,
					col = center_x,
					width = window_w_int,
					height = window_h_int,
					title = " Explorer ",
					title_pos = "center",
				}
			end,
		},
		width = function()
			return math.floor(vim.opt.columns:get() * 0.4)
		end,
	},
})

-- NvimTreeSignColumn links to NvimTreeNormal (sidebar bg), not NvimTreeNormalFloat,
-- which leaves the sign column grey even though the rest of the float is black.
vim.api.nvim_set_hl(0, "NvimTreeNormal", { link = "NvimTreeNormalFloat" })
vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { link = "NvimTreeNormalFloat" })

vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
