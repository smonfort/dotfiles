-- 🏙 A clean, dark Neovim theme written in Lua, with support for lsp, treesitter and lots of plugins.
-- Includes additional themes for Kitty, Alacritty, iTerm and Fish.
return {
	{
		"folke/tokyonight.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require("tokyonight").setup({
				style = "night",
			})
			vim.cmd([[
        colorscheme tokyonight
      ]])
		end,
	},
}
