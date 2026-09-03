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

require("grammar_fix").bind()
require("hyperkeys").bind()
