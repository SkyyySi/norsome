----------------------------------------------------------------------------------------------------
--                                       Load config files                                        --
----------------------------------------------------------------------------------------------------

-- Error handling
dofile(awful.util.getdir("config") .. "rc.d/error-handler.lua")

-- Variable definitions
dofile(awful.util.getdir("config") .. "rc.d/variables.lua")

-- Menu
dofile(awful.util.getdir("config") .. "rc.d/menu.lua")

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Wibar/panel
dofile(awful.util.getdir("config") .. "rc.d/wibar.lua")

-- Key and mouse bindings
dofile(awful.util.getdir("config") .. "rc.d/bindings.lua")

-- Rules
dofile(awful.util.getdir("config") .. "rc.d/rules.lua")

-- Signals
dofile(awful.util.getdir("config") .. "rc.d/signals.lua")
