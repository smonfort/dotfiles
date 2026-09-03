local HERE = os.getenv("HOME") .. "/.hammerspoon/"

-- ~/.hammerspoon is symlinked (stow); also watch init.lua's real target dir.
local realInit = hs.fs.pathToAbsolute(HERE .. "init.lua")
local WATCHED_PATHS = { HERE, realInit:match("(.*/)") }

local watchers = {}
for _, path in ipairs(WATCHED_PATHS) do
    local watcher = hs.pathwatcher.new(path, hs.reload)
    watcher:start()
    table.insert(watchers, watcher)
end

hs.alert.show("Hammerspoon config loaded")

-- Auto-loads plugin/*.lua, like Neovim's plugin/ directory.
local PLUGIN_DIR = HERE .. "plugin"
package.path = package.path .. ";" .. PLUGIN_DIR .. "/?.lua"

for file in hs.fs.dir(PLUGIN_DIR) do
    if file:match("%.lua$") then
        local plugin = require((file:gsub("%.lua$", "")))
        if plugin.bind then
            plugin.bind()
        end
    end
end
