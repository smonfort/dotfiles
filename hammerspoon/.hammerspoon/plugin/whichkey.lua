-- Hyper + ?: which-key-style overview of every hyperkey binding, read live
-- from AeroSpace's config and this Hammerspoon config.

local hyper = require("hyper")
local THEME = require("theme")
local render = require("html").render
local escape = require("html").escape

-- keycode 46 (M) types "," unshifted, "?" shifted — same AZERTY issue as
-- "=" / "-" in switch_tmux_session.lua / switch_claude_session.lua.
local TOGGLE_KEY = hs.keycodes.map[46]

local AEROSPACE_CONFIG = os.getenv("HOME") .. "/.config/aerospace/aerospace.toml"

-- "move-workspace-to-monitor --wrap-around next" -> "Move workspace to monitor next"
local function prettifyCommand(command)
    local text = command:gsub("%-%-[%w%-]+%s*", "")
    text = text:gsub("%-", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text:sub(1, 1):upper() .. text:sub(2)
end

-- Pulls hyperkey bindings out of [mode.main.binding] in AeroSpace's live config.
local function parseAerospaceBindings()
    local file = io.open(AEROSPACE_CONFIG, "r")
    if not file then return nil end

    local inSection = false
    local groups = { focus = {}, workspace = {}, monitor = {}, other = {} }

    for line in file:lines() do
        if line:match("^%[mode%.main%.binding%]%s*$") then
            inSection = true
        elseif inSection and line:match("^%[") then
            inSection = false
        elseif inSection then
            local keyNotation, rawValue = line:match("^%s*([%w%-]+)%s*=%s*(.+)$")
            local letter = keyNotation and keyNotation:match("^cmd%-alt%-ctrl%-shift%-(.+)$")
            local command = letter and rawValue:match("['\"]([^'\"]+)['\"]")

            if command then
                if command:match("^focus %a+$") then
                    table.insert(groups.focus, { key = letter, label = prettifyCommand(command) })
                elseif command:match("^workspace %u$") then
                    table.insert(groups.workspace, { key = letter })
                elseif command:match("^move%-workspace%-to%-monitor") then
                    table.insert(groups.monitor, { key = letter, label = prettifyCommand(command) })
                else
                    table.insert(groups.other, { key = letter, label = prettifyCommand(command) })
                end
            end
        end
    end
    file:close()

    for _, group in pairs(groups) do
        table.sort(group, function(a, b) return a.key < b.key end)
    end
    return groups
end

local function keycap(text)
    return '<span class="key">' .. escape(text:upper()) .. "</span>"
end

local function row(keyText, label)
    return string.format('<div class="row">%s<span class="label">%s</span></div>', keycap(keyText), escape(label))
end

local function section(title, bodyHtml, caption)
    local captionHtml = caption and ('<div class="caption">' .. escape(caption) .. "</div>") or ""
    return string.format(
        '<div class="section"><div class="section-title">%s</div>%s%s</div>',
        escape(title), captionHtml, bodyHtml
    )
end

local function buildHtml()
    local groups = parseAerospaceBindings() or { focus = {}, workspace = {}, monitor = {}, other = {} }
    local sections = {}

    local launchBindings = {}
    for _, item in ipairs(hyper.bindings()) do
        if item.group == "focus" then
            table.insert(groups.focus, { key = item.key, label = item.description })
        else
            table.insert(launchBindings, item)
        end
    end

    if #groups.focus > 0 then
        local rows = {}
        for _, item in ipairs(groups.focus) do
            table.insert(rows, row(item.key, item.label))
        end
        table.insert(sections, section("Focus", table.concat(rows)))
    end

    if #groups.workspace > 0 then
        local badges = {}
        for _, item in ipairs(groups.workspace) do
            table.insert(badges, keycap(item.key))
        end
        local grid = '<div class="grid">' .. table.concat(badges) .. "</div>"
        table.insert(sections, section("Workspaces", grid, "Switch to the matching workspace"))
    end

    if #groups.monitor > 0 then
        local rows = {}
        for _, item in ipairs(groups.monitor) do
            table.insert(rows, row(item.key, item.label))
        end
        table.insert(sections, section("Monitor", table.concat(rows)))
    end

    local rows = {}
    for _, item in ipairs(launchBindings) do
        table.insert(rows, row(item.key, item.description))
    end
    table.insert(sections, section("Launch", table.concat(rows)))

    if #groups.other > 0 then
        local otherRows = {}
        for _, item in ipairs(groups.other) do
            table.insert(otherRows, row(item.key, item.label))
        end
        table.insert(sections, section("Other", table.concat(otherRows)))
    end

    local vars = {}
    for k, v in pairs(THEME) do vars[k] = v end
    vars.SECTIONS = table.concat(sections)

    return render([[
    <html><head><style>
      body {
        margin: 0; font-family: {{FONT}};
        background: {{BG}}; color: {{FG}};
        display: flex; flex-direction: column; height: 100vh;
        box-sizing: border-box;
      }
      .header {
        padding: 10px 16px; font-size: 13px; font-weight: 600;
        border-bottom: 1px solid {{BORDER}};
        display: flex; justify-content: space-between; align-items: baseline;
        flex-shrink: 0;
      }
      .hint { font-size: 11px; font-weight: 400; color: {{COMMENT}}; }
      .body { flex: 1; overflow-y: auto; padding: 12px 16px; }
      .section { margin-bottom: 16px; }
      .section-title {
        font-size: 11px; text-transform: uppercase; letter-spacing: 0.05em;
        color: {{COMMENT}}; margin-bottom: 8px;
      }
      .caption { font-size: 12px; color: {{FG_DARK}}; margin-bottom: 8px; }
      .row {
        display: flex; align-items: center; gap: 10px;
        padding: 3px 0; font-size: 13px;
      }
      .grid { display: flex; flex-wrap: wrap; gap: 6px; }
      .key {
        display: inline-flex; align-items: center; justify-content: center;
        min-width: 22px; padding: 2px 7px;
        background: {{BG_HIGHLIGHT}}; border: 1px solid {{BORDER}};
        border-radius: 6px; color: {{PURPLE}};
        font-size: 12px; font-weight: 600;
      }
      .label { color: {{FG_DARK}}; }
    </style></head>
    <body>
      <div class="header">
        <div>&#8984; &#8997; &#8963; &#8679; Hyperkey map</div>
        <div class="hint">Esc, click outside, or hyper+? to close</div>
      </div>
      <div class="body">{{SECTIONS}}</div>
    </body></html>
    ]], vars)
end

local overlayWindow = nil
local closeWatchers = {}

local function stopCloseWatchers()
    for _, watcher in ipairs(closeWatchers) do
        watcher:stop()
    end
    closeWatchers = {}
end

local function hide()
    stopCloseWatchers()
    if overlayWindow then
        overlayWindow:delete()
        overlayWindow = nil
    end
end

local function show()
    local screenFrame = hs.screen.mainScreen():frame()
    local w = math.min(640, screenFrame.w * 0.6)
    local h = math.min(560, screenFrame.h * 0.75)
    local rect = hs.geometry.rect(
        screenFrame.x + (screenFrame.w - w) / 2,
        screenFrame.y + (screenFrame.h - h) / 2,
        w, h
    )

    overlayWindow = hs.webview.new(rect)
    overlayWindow:windowStyle(hs.webview.windowMasks.borderless)
    overlayWindow:allowTextEntry(false)
    overlayWindow:level(hs.drawing.windowLevels.overlay)
    overlayWindow:transparent(true) -- avoids a white flash before the page's own CSS paints
    overlayWindow:html(buildHtml())
    overlayWindow:show()
    overlayWindow:bringToFront(true)

    local frame = overlayWindow:frame()

    local escWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        if event:getKeyCode() == hs.keycodes.map["escape"] then
            hide()
        end
        return false
    end)
    escWatcher:start()

    local clickWatcher = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function(event)
        local point = event:location()
        local outside = point.x < frame.x or point.x > frame.x + frame.w
            or point.y < frame.y or point.y > frame.y + frame.h
        if outside then
            hide()
        end
        return false
    end)
    clickWatcher:start()

    closeWatchers = { escWatcher, clickWatcher }
end

local function toggle()
    if overlayWindow then
        hide()
    else
        show()
    end
end

hyper.bind(TOGGLE_KEY, "Show hyperkey map", toggle)
