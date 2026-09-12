local hyper = require("hyper")
local task = require("task")

-- keycode 27 (kVK_ANSI_Minus): "-" needs its own shift on this AZERTY
-- keyboard, which collides with hyper's.
hyper.bind(hs.keycodes.map[27], "Show workmux dashboard", function()
    task.run("/bin/bash", {
        "-c",
        'source ~/.config/tmux/focus-workmux-dashboard.sh && focus_workmux_dashboard',
    })
end)
