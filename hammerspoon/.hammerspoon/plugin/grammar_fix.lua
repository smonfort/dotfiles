-- Hyper + $ : sends the clipboard text to Claude for grammar/syntax correction into
-- English, shows a loading window then a two-column comparison, and copies the
-- corrected text back to the clipboard.

local M = {}

-- Exposed so whichkey.lua can list this binding without duplicating it.
M.KEY = "$"
M.LABEL = "Grammar fix"

local CLAUDE_BIN = "/opt/homebrew/bin/claude"
local MODEL = "haiku"
local TIMEOUT_SECONDS = 25

local SYSTEM_PROMPT = "You are a grammar and syntax correction engine. Rewrite the user's "
	.. "text in correct, natural, fluent English. If the input is not in English, translate "
	.. "it into fluent English. Preserve the original meaning, tone, and formatting (line "
	.. "breaks, lists, markdown). Output ONLY the corrected text, with no preamble, no "
	.. "explanation, and no surrounding quotes."

-- TokyoNight Night palette, matching nvim (tokyonight.nvim, style="night") and wezterm's font.
local THEME = {
	BG = "#1a1b26",
	BG_HIGHLIGHT = "#292e42",
	FG = "#c0caf5",
	FG_DARK = "#a9b1d6",
	COMMENT = "#565f89",
	BORDER = "#3b4261",
	GREEN = "#9ece6a",
	GREEN_TINT = "rgba(158, 206, 106, 0.08)",
	PURPLE = "#bb9af7",
	FONT = "'JetBrainsMono Nerd Font Mono', Menlo, monospace",
}

local function render(template, vars)
	return (template:gsub("{{([%u_]+)}}", function(key)
		return vars[key] or ""
	end))
end

local function hexColor(hex, alpha)
	local r, g, b = hex:match("#(%x%x)(%x%x)(%x%x)")
	return {
		red = tonumber(r, 16) / 255,
		green = tonumber(g, 16) / 255,
		blue = tonumber(b, 16) / 255,
		alpha = alpha or 1,
	}
end

local function showAlert(text)
	hs.alert.show(text, {
		fillColor = hexColor(THEME.BG, 0.95),
		strokeColor = hexColor(THEME.BORDER, 1),
		textColor = hexColor(THEME.FG, 1),
		textFont = "JetBrainsMono Nerd Font Mono",
		textSize = 16,
		radius = 8,
	})
end

local loadingWindow = nil
local resultWindow = nil
local closeWatchers = {}

local function htmlEscape(s)
	if not s then
		return ""
	end
	s = s:gsub("&", "&amp;")
	s = s:gsub("<", "&lt;")
	s = s:gsub(">", "&gt;")
	return s
end

local function stopCloseWatchers()
	for _, watcher in ipairs(closeWatchers) do
		watcher:stop()
	end
	closeWatchers = {}
end

local function closeResultWindow()
	stopCloseWatchers()
	if resultWindow then
		resultWindow:delete()
		resultWindow = nil
	end
end

local function hideLoadingWindow()
	if loadingWindow then
		loadingWindow:delete()
		loadingWindow = nil
	end
end

local function showLoadingWindow()
	local screenFrame = hs.screen.mainScreen():frame()
	local w, h = 260, 90
	local rect =
		hs.geometry.rect(screenFrame.x + (screenFrame.w - w) / 2, screenFrame.y + (screenFrame.h - h) / 2, w, h)

	local html = render(
		[[
    <html><head><style>
      body {
        margin: 0; display: flex; align-items: center; justify-content: center;
        height: 100vh; font-family: {{FONT}};
        background: {{BG}}; color: {{FG}};
      }
      .row { display: flex; align-items: center; }
      .spinner {
        width: 20px; height: 20px; border-radius: 50%;
        border: 3px solid {{BORDER}};
        border-top-color: {{PURPLE}};
        animation: spin 0.8s linear infinite;
        margin-right: 12px;
      }
      @keyframes spin { to { transform: rotate(360deg); } }
      .label { font-size: 14px; }
    </style></head>
    <body>
      <div class="row"><div class="spinner"></div><div class="label">Correcting...</div></div>
    </body></html>
    ]],
		THEME
	)

	loadingWindow = hs.webview.new(rect)
	loadingWindow:windowStyle(hs.webview.windowMasks.borderless)
	loadingWindow:allowTextEntry(false)
	loadingWindow:level(hs.drawing.windowLevels.overlay)
	loadingWindow:html(html)
	loadingWindow:show()
end

local function showResultWindow(originalText, correctedText)
	local screenFrame = hs.screen.mainScreen():frame()
	local w = math.min(1000, screenFrame.w * 0.8)
	local h = math.min(600, screenFrame.h * 0.7)
	local rect =
		hs.geometry.rect(screenFrame.x + (screenFrame.w - w) / 2, screenFrame.y + (screenFrame.h - h) / 2, w, h)

	local vars = {}
	for k, v in pairs(THEME) do
		vars[k] = v
	end
	vars.ORIGINAL = htmlEscape(originalText)
	vars.CORRECTED = htmlEscape(correctedText)

	local html = render(
		[[
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
      .columns { flex: 1; display: flex; overflow: hidden; }
      .col {
        flex: 1; padding: 14px 16px; overflow-y: auto;
        white-space: pre-wrap; word-wrap: break-word;
        font-size: 14px; line-height: 1.5;
        box-sizing: border-box;
      }
      .col + .col { border-left: 1px solid {{BORDER}}; }
      .col-title {
        font-size: 11px; text-transform: uppercase; letter-spacing: 0.05em;
        color: {{COMMENT}}; margin-bottom: 8px;
      }
      .right { background: {{GREEN_TINT}}; }
    </style></head>
    <body>
      <div class="header">
        <div>Grammar correction</div>
        <div class="hint">Esc or click outside to close — the right-hand text is already copied</div>
      </div>
      <div class="columns">
        <div class="col">
          <div class="col-title">Original</div>{{ORIGINAL}}
        </div>
        <div class="col right">
          <div class="col-title">Corrected</div>{{CORRECTED}}
        </div>
      </div>
    </body></html>
    ]],
		vars
	)

	resultWindow = hs.webview.new(rect)
	resultWindow:windowStyle(hs.webview.windowMasks.borderless)
	resultWindow:allowTextEntry(false)
	resultWindow:html(html)
	resultWindow:show()
	resultWindow:bringToFront(true)

	local frame = resultWindow:frame()

	local escWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
		if event:getKeyCode() == hs.keycodes.map["escape"] then
			closeResultWindow()
		end
		return false
	end)
	escWatcher:start()

	local clickWatcher = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function(event)
		local point = event:location()
		local outside = point.x < frame.x
			or point.x > frame.x + frame.w
			or point.y < frame.y
			or point.y > frame.y + frame.h
		if outside then
			closeResultWindow()
		end
		return false
	end)
	clickWatcher:start()

	closeWatchers = { escWatcher, clickWatcher }
end

local function handleClaudeResult(exitCode, stdOut, stdErr, originalText, timedOut)
	hideLoadingWindow()

	if timedOut then
		showAlert("Correction cancelled: timed out")
		return
	end

	if exitCode ~= 0 or not stdOut or stdOut:gsub("%s", "") == "" then
		local reason = (stdErr and stdErr:gsub("%s", "") ~= "") and stdErr or ("exit " .. tostring(exitCode))
		showAlert("claude CLI error: " .. reason)
		return
	end

	local correctedText = stdOut:gsub("%s+$", "")

	hs.pasteboard.setContents(correctedText)
	showAlert("Copied!")

	showResultWindow(originalText, correctedText)
end

local function runCorrection()
	local originalText = hs.pasteboard.readString()

	if not originalText or originalText:gsub("%s", "") == "" then
		showAlert("Clipboard is empty or not text")
		return
	end

	showLoadingWindow()

	local timedOut = false

	local task = hs.task.new(CLAUDE_BIN, function(exitCode, stdOut, stdErr)
		if timedOut then
			return
		end
		handleClaudeResult(exitCode, stdOut, stdErr, originalText, false)
	end, {
		"-p",
		"--model",
		MODEL,
		"--tools",
		"",
		"--effort",
		"low",
		"--system-prompt",
		SYSTEM_PROMPT,
		"--output-format",
		"text",
	})

	task:setInput(originalText)
	task:start()

	hs.timer.doAfter(TIMEOUT_SECONDS, function()
		if task:isRunning() then
			timedOut = true
			task:terminate()
			handleClaudeResult(nil, nil, nil, originalText, true)
		end
	end)
end

function M.bind()
	hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, M.KEY, runCorrection)
end

return M
