local hyper = require("hyper")
local task = require("task")

-- keycode 27 (kVK_ANSI_Minus): "-" needs its own shift on this AZERTY
-- keyboard, which collides with hyper's.
hyper.bind(hs.keycodes.map[27], "Switch Claude session", function()
    task.run("/opt/homebrew/bin/vicinae", { "vicinae://launch/@smonfort/claude-sessions/switch" })
end)
