-- Hyperkey bindings that launch something, as opposed to AeroSpace's own
-- hyperkey bindings (focus/move/workspace/resize), which stay in its config.

local M = {}

local HYPER = { "cmd", "alt", "ctrl", "shift" }

-- Reverse-lookup by virtual keycode (kVK_ANSI_Equal/Minus): on this AZERTY
-- keyboard "=" and "-" need their own modifier, which collides with hyper.
local KEY_EQUAL = hs.keycodes.map[24]
local KEY_MINUS = hs.keycodes.map[27]

-- hs.task is GC'd (and killed) once unreferenced, so keep every one here.
local runningTasks = {}

local function runTask(launchPath, arguments)
	local task = hs.task.new(launchPath, nil, arguments or {})
	table.insert(runningTasks, task)
	task:start()
end

local BINDINGS = {
	-- Vicinae popup to switch tmux session
	{
		key = KEY_EQUAL,
		action = function()
			runTask(os.getenv("HOME") .. "/.config/vicinae/scripts/switch-session-vicinae.sh")
		end,
	},
	-- Vicinae "Switch Claude Session" extension
	{
		key = KEY_MINUS,
		action = function()
			runTask("/opt/homebrew/bin/vicinae", { "vicinae://launch/@smonfort/claude-sessions/switch" })
		end,
	},
}

function M.bind()
	for _, binding in ipairs(BINDINGS) do
		hs.hotkey.bind(HYPER, binding.key, binding.action)
	end
end

return M
