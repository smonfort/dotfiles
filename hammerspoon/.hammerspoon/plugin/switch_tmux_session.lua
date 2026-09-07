local hyper = require("hyper")
local task = require("task")

-- keycode 24 (kVK_ANSI_Equal): "=" needs its own shift on this AZERTY
-- keyboard, which collides with hyper's.
hyper.bind(hs.keycodes.map[24], "Switch tmux session", function()
    task.run("/opt/homebrew/bin/vicinae", { "vicinae://launch/@smonfort/tmux-sessions/switch" })
end)
