local hyper = require("hyper")
local task = require("task")

-- keycode 29 (kVK_ANSI_0): digits need their own shift on this AZERTY
-- keyboard, which collides with hyper's.
hyper.bind(hs.keycodes.map[29], "Focus window (search)", function()
    task.run("/opt/homebrew/bin/vicinae", { "vicinae://launch/@smonfort/aerospace-workspaces/switch" })
end, { group = "focus" })
