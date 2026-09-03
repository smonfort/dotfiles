hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()

hs.alert.show("Hammerspoon config loaded")

require("grammar_fix").bind()
