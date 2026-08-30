vim.pack.add({
	gh("folke/tokyonight.nvim"),
})

require("tokyonight").setup({
	style = "night",
	transparent = true,
	styles = {
		sidebars = "transparent",
		floats = "transparent",
	},
})
vim.cmd([[colorscheme tokyonight]])

-- tokyonight hardcodes StatusLine/StatusLineNC to an opaque bg_statusline
-- background regardless of the transparent option above (it's only meant to
-- soften the split between windows), which leaves the statusbar solid even
-- though lualine's own theme (02-lualine.lua) is transparent.
vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
