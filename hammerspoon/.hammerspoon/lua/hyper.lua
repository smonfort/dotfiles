-- Hyperkey binding helper, styled like `vim.keymap.set(mode, lhs, rhs, { desc = ... })`:
-- one call both binds the key and records it for whichkey.lua to list.

local M = {}

local MODS = { "cmd", "alt", "ctrl", "shift" }
local bindings = {}

function M.bind(key, description, fn)
    table.insert(bindings, { key = key, description = description })
    hs.hotkey.bind(MODS, key, fn)
end

function M.bindings()
    return bindings
end

return M
