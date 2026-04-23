-- Neovim Lua plugin for fast and familiar per-line commenting. Part of 'mini.nvim' library.
return {
	"nvim-mini/mini.nvim",
	version = "*",
	config = function()
		require("mini.comment").setup()
	end,
}
