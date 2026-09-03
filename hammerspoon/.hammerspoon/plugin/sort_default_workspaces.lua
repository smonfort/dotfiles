local hyper = require("hyper")
local task = require("task")

-- keycode 25 (kVK_ANSI_9): digits need their own shift on this AZERTY
-- keyboard, which collides with hyper's.
hyper.bind(hs.keycodes.map[25], "Sort open apps into default AeroSpace workspaces", function()
    task.run(os.getenv("HOME") .. "/.config/aerospace/scripts/move-to-default-workspaces.sh")
end)
