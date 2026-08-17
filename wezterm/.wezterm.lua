local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 14
config.window_decorations = "RESIZE"

return config
