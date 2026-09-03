-- ~/.hammerspoon only holds symlinks (dotfiles' `stow` setup); also watch the
-- real source tree, since editing a symlink's target doesn't touch this dir.
local WATCHED_PATHS = {
    os.getenv("HOME") .. "/.hammerspoon/",
    os.getenv("HOME") .. "/git/github/smonfort/dotfiles/hammerspoon/.hammerspoon/",
}

local watchers = {}
for _, path in ipairs(WATCHED_PATHS) do
    local watcher = hs.pathwatcher.new(path, hs.reload)
    watcher:start()
    table.insert(watchers, watcher)
end

hs.alert.show("Hammerspoon config loaded")

-- Each file under plugin/ is self-contained, like Neovim's plugin/ directory:
-- loaded automatically, no wiring needed here.
local PLUGIN_DIR = os.getenv("HOME") .. "/.hammerspoon/plugin"
package.path = package.path .. ";" .. PLUGIN_DIR .. "/?.lua"

for file in hs.fs.dir(PLUGIN_DIR) do
    if file:match("%.lua$") then
        local plugin = require((file:gsub("%.lua$", "")))
        if plugin.bind then
            plugin.bind()
        end
    end
end
