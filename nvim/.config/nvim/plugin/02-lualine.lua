vim.pack.add({
	gh("nvim-lualine/lualine.nvim"),
})

vim.opt.showmode = false -- lualine already shows the mode, avoid the duplicate "-- INSERT --" on the command line

-- require the tokyonight theme generator directly: lualine.nvim also ships a static
-- "tokyonight" theme under the same module name, and depending on runtimepath order
-- `theme = "tokyonight"` can resolve to that stale snapshot instead of the colors
-- actually configured in 00-colorscheme.lua (style + on_colors black background).
local tokyonight_theme = require("lualine.themes._tokyonight").get()
local colors = require("tokyonight.colors").setup()

-- The theme's "c" sections (and inactive's "a"/"b") paint a solid
-- bg_statusline background that fills the whole bar, clashing with the
-- transparent colorscheme (00-colorscheme.lua). Only the mode pill (styled
-- via "a") should keep its own background; everything else goes transparent.
for _, mode in pairs(tokyonight_theme) do
	if mode.c then
		mode.c.bg = "none"
	end
end
if tokyonight_theme.inactive then
	if tokyonight_theme.inactive.a then
		tokyonight_theme.inactive.a.bg = "none"
	end
	if tokyonight_theme.inactive.b then
		tokyonight_theme.inactive.b.bg = "none"
	end
end

-- section_separators chains the same round cap between every section, which draws
-- overlapping half-circles instead of a clean pill. Only "mode" should look like a
-- pill (matching the tmux status bar); other sections stay flat text.
-- Wraps a single component in round caps ("" / "") instead of chaining section_separators.
local mode_pill = { "mode", separator = { left = "", right = "" } }

-- Hides "on <branch>" on unnamed buffers, where there's no filename for it to follow.
local has_filename = function()
	return vim.fn.expand("%:t") ~= ""
end

-- Explicit bg keeps it constant across modes regardless of which section it ends up
-- in (see branch's per-mode quirk noted elsewhere).
local branch_component = {
	"branch",
	color = { fg = colors.cyan, bg = "none", gui = "bold" },
	padding = { left = 0, right = 1 },
	cond = has_filename,
}

-- Literal "on" between filename and branch, styled like starship's comment-grey text.
local on_label = {
	function()
		return "on"
	end,
	color = { fg = colors.fg_dark },
	padding = { left = 1, right = 1 },
	cond = has_filename,
}

-- Muted chevron before the filename, same idea as the "->" before "dotfiles"
-- in the tmux status-left format (grey glyph, colored text right after it).
local filename_icon = {
	function()
		return has_filename() and "❯" or ""
	end,
	color = { fg = colors.comment },
	padding = { left = 3, right = 1 },
}

local function listed_buffer_count()
	return #vim.tbl_filter(function(bufnr)
		return vim.fn.buflisted(bufnr) == 1
	end, vim.api.nvim_list_bufs())
end

-- Hidden with 0 or 1 buffer (the common case) since it'd otherwise always read "1".
local buffer_count = {
	function()
		return "≡ " .. listed_buffer_count()
	end,
	color = { fg = colors.fg_dark, bg = "none" },
	cond = function()
		return listed_buffer_count() > 1
	end,
}

-- A plain "[+]"/"[-]" reads as an afterthought; a colored dot/lock stand out the way
-- an editor's dirty-tab indicator does. file_status is turned off on filename below
-- so these two replace it instead of stacking on top.
local modified_indicator = {
	function()
		return vim.bo.modified and "●" or ""
	end,
	color = { fg = colors.yellow },
	padding = { left = 1, right = 0 },
}
local readonly_indicator = {
	function()
		return (not vim.bo.modifiable or vim.bo.readonly) and "" or ""
	end,
	color = { fg = colors.red },
	padding = { left = 1, right = 0 },
}

require("lualine").setup({
	options = {
		theme = tokyonight_theme,
		icons_enabled = true,
		component_separators = "",
		section_separators = "",
		globalstatus = true,
	},
	sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {
			filename_icon,
			-- starship's directory module: bold cyan
			{
				"filename",
				file_status = false,
				symbols = { unnamed = "" },
				color = { fg = colors.magenta, gui = "bold" },
				padding = { left = 0, right = 0 },
			},
			modified_indicator,
			readonly_indicator,
			on_label,
			branch_component,
			"diagnostics",
		},
		lualine_x = {},
		lualine_y = { buffer_count },
		lualine_z = { mode_pill },
	},
	inactive_sections = {},
	extensions = {
		{
			filetypes = { "NvimTree" },
			sections = {},
		},
	},
})
