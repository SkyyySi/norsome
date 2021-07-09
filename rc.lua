----------------------------------------------------------------------------------------------------
--                                       Initialize awesome                                       --
----------------------------------------------------------------------------------------------------

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, 'luarocks.loader')

-- Awesome librarys
gears         = require('gears')
shape         = require('gears.shape')
awful         = require('awful')
wibox         = require('wibox')
beautiful     = require('beautiful')
naughty       = require('naughty')
menubar       = require('menubar')
hotkeys_popup = require('awful.hotkeys_popup')
xresources    = require('beautiful.xresources')
dpi           = xresources.apply_dpi

-- Add the local module and widget directory to awesome's path
package.path = package.path .. ';' .. awful.util.getdir('config') .. 'modules/?.lua'

require('awful.autofocus')
require('base')

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require('awful.hotkeys_popup.keys')

-- Autostart applications
--awful.spawn(awful.util.getdir('config') .. '/scipts/autostart.sh')

-- Error handling
require('error-handler')

-- Early auto start for daemon processes
awful.spawn.with_shell('playerctl daemon')

-- {{{ Variable definitions
theme       = 'nord'
terminal    = 'alacritty'
webbrowser  = 'firefox'
filemanager = 'pcmanfm-qt'
editor      = 'code'
editor_cmd  = editor
config_dir  = awful.util.getdir('config')
themes_dir  = config_dir .. 'themes/'
theme_dir   = themes_dir .. theme .. '/'

-- Themes define colours, icons, font and wallpapers.
beautiful.init(theme_dir .. 'theme.lua')

if ( terminal == 'alacritty' and filecheck.read(theme_dir .. 'alacritty.yml') ) then
	local term_themed = 'sh -c "alacritty -o \\"$(/usr/bin/env cat ' .. theme_dir .. 'alacritty.yml' .. ')\\""'
	terminal          = term_themed
end

-- Load bling for extra stuff
bling = require('bling')
bling.signal.playerctl.enable()
if filecheck.read(os.getenv('HOME') .. '/.cache/awesome/cover.png') then
	awful.spawn({'rm', '-f', (os.getenv('HOME') .. '/.cache/awesome/cover.png')})
end

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
-- Tip: Alt is Mod1
modkey = 'Mod4'

-- Table of layouts to cover with awful.layout.inc, order matters.
--awful.layout.layouts = {
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
		awful.layout.suit.spiral,
		awful.layout.suit.floating,
		--awful.layout.suit.max,
	--[[ Full list:
		awful.layout.suit.floating,
		awful.layout.suit.tile,
		awful.layout.suit.tile.left,
		awful.layout.suit.tile.bottom,
		awful.layout.suit.tile.top,
		awful.layout.suit.fair,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.spiral,
		awful.layout.suit.spiral.dwindle,
		awful.layout.suit.max,
		awful.layout.suit.max.fullscreen,
		awful.layout.suit.magnifier,
		awful.layout.suit.corner.nw,
		awful.layout.suit.corner.ne,
		awful.layout.suit.corner.sw,
		awful.layout.suit.corner.se,
	]]--
    })
end)
--}
-- }}}

-- {{{ Menu
awesome_menu = require('widgets.awesome_menu')

--- EXTERNAL FILES ---
--local qrlinux  = {}
--qrlinux.widget = {}

-- Signals
require('signals.get_volume')
require('signals.get_song')

-- Modules
rounded_rectangle    = require('rounded_rectangle')
infobubble           = require('infobubble')
rounded_wibox        = require('rounded_wibox')
buttonify            = require('buttonify')
hsl                  = require('hsl')
double_border_widget = require('double_border_widget')
make_widget          = require('make_widget')

-- Widgets
--local menubutton        = require('widgets.menubutton')

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

----------------------------------------------------------------------------------------------------
--                                             WIDGETS                                            --
----------------------------------------------------------------------------------------------------

-- {{{ Wibar
qrwidget = {}

qrwidget.music            = require('widgets.music')            -- MUSIC CONTROL
qrwidget.volume           = require('widgets.volume')           -- VOLUME CONTROL
qrwidget.calendar         = require('widgets.calendar')         -- CALENDAR
qrwidget.kbdlayout        = require('widgets.keyboard')         -- KEYBOARD LAYOUT
qrwidget.taglist          = require('widgets.taglist')          -- TAGLIST
qrwidget.tasklist         = require('widgets.tasklist')         -- TASKLIST
qrwidget.current_layout   = require('widgets.current_layout')   -- CURRENT LAYOUT
qrwidget.systray          = require('widgets.systray')          -- SYSTEM TRAY
qrwidget.menubutton       = require('widgets.menubutton')       -- START MENU BUTTON
qrwidget.wallpaper_select = require('widgets.wallpaper_select') -- WALLPAPER SELECTOR

qrwidget.night_mode       = require('night_mode')
--qrwidget.notification_bar = require('notifications') -- NOTIFICATION BAR
--qrwidget.notification_bar()

qrwidget.control_panel    = require('modules.widgets.control_panel') -- CONTROL PANEL

-- Wallpaper
local function set_wallpaper(s)
	awful.spawn('nitrogen --restore')
	--awful.spawn('hsetroot -add '#2e3440' -add '#eceff4' -gradient 180')
    --[[ if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == 'function' then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end ]]
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal('request::wallpaper', set_wallpaper)
screen.connect_signal('property::geometry', set_wallpaper)

--naughty.notify{text=hsl(0, 0, 0)}

--[[ -- Make it a local function instead of a global one.
local myfirstwidget
-- Define the function for adding the widget. The purpose is to make adding
-- it to multiple screens easier as well as making it easier to move
-- into external files (to keep your rc.lua clean).
function myfirstwidget(s)
	-- This defines the screen to show the widget on. This is primarily
	-- usefull if you use multiple screens. If you don't, I still recommend
	-- using this, as if you ever happen to optain one, it'll save you time
	-- one adding this in afterwards. Also, you should definitely do this if
	-- you ever plan on making you dotfiles public. And in addition to that,
	-- it also doesn't really add any complexety (in fact, it can reduce it).
	--
	-- Either the screen passed as an argument or the primary screen as a fallback.
	local screen = s or screen.primary

	-- You should use s.<name of widget> if you use the `s` argument above.
	-- If not, something like
	--local <name of widget> = wibox.widget { ... }
	-- will also work.
	-- Note that the name ("main_widget" in this case) doesn't matter as login
	-- as it is a valid name in lua (if you use an IDE or linter, you'll see
	-- if it's valid or not).
	s.main_widget = wibox.widget {
		text   = "Hello, world!",
		widget = wibox.widget.textbox,
	}

	-- Send a notificaion if the widget was clicked on.
	s.main_widget:connect_signal('button::press', function(c, _, _, b)
		if b == 1 then
			naughty.notify({ text = 'Left mouse click' })
		elseif b == 2 then
			naughty.notify({ text = 'Wheel click' })
		elseif b == 3 then
			naughty.notify({ text = 'Right mouse click' })
		end
	end)

	-- Return the widget when the function is called, making it usable in awesome.
	-- Use the name you set above.
	return s.main_widget
end ]]

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ '1', '2', '3', '4', '5', '6', '7', '8', '9', }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.promptbox = awful.widget.prompt()

	--[[ s.desktop_volslide  = make_widget {
		widget = require('widgets.control_panel.widgets.volume'),
		mode   = 'desktop',
		screen = s,
		--shape  = rounded_rectangle(dpi(5)),
		width  = dpi(350),
		height = dpi(60),
		desktop_margins = {
			right  = dpi(40),
			bottom = dpi(320),
		}
	} ]]

	--[[ s.desktop_calendar  = make_widget {
		widget          = require('widgets.control_panel.widgets.calendar'),
		mode            = 'desktop',
		screen          = s,
		--shape           = rounded_rectangle(dpi(5)),
		width           = dpi(192),
		height          = dpi(230),
		placement       = 'bottom_right',
		desktop_margins = {
			bottom = dpi(40),
			right  = dpi(40),
		}
	} ]]

	-- Create the top wibar
	s.topwibar   = awful.wibar({
		bg       = (beautiful.bar_bg or ((beautiful.bg_normal or '#2E3440') .. 'E0')),
		position = 'top',
		stretch  = true,
		ontop    = false,
		screen   = s,
		height   = dpi(40)
	})

	-- Add widgets to the top wibar
	s.topwibar.widget = {
		{ -- Right
			qrwidget.menubutton(s),
			qrwidget.taglist(s),
			awful.widget.prompt(),
			margins = dpi(4),
			widget  = wibox.container.margin,
			layout  = wibox.layout.align.horizontal,
		},
		{ -- Center
			nil,
			qrwidget.tasklist(s),
			nil,
			expand = 'outside',
			layout = wibox.layout.align.horizontal,
		},
		{ -- Left
			--qrwidget.music(s),
			qrwidget.volume(s),
			--qrwidget.wallpaper_select(s, {}), -- Disabled for now.
			qrwidget.kbdlayout(s),
			qrwidget.calendar(s),
			qrwidget.systray(screen.primary),
			qrwidget.control_panel(s),
			qrwidget.current_layout(s),
			layout = wibox.layout.fixed.horizontal,
		},
		layout    = wibox.layout.align.horizontal,
	}
end)
-- }}}

-- {{{ Mouse bindings
require('modules.bindings.mouse.root')
local clientbuttons = require('modules.bindings.mouse.clientbuttons')
-- }}}

-- {{{ Key bindings
local globalkeys    = require('modules.bindings.keyboard.globalkeys')
local clientkeys    = require('modules.bindings.keyboard.clientkeys')

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ modkey }, '#' .. i + 9,
				  function ()
						local screen = awful.screen.focused()
						local tag = screen.tags[i]
						if tag then
						   tag:view_only()
						end
				  end,
				  {description = 'view tag #'..i, group = 'tag'}),
		-- Toggle tag display.
		awful.key({ modkey, 'Control' }, '#' .. i + 9,
				  function ()
					  local screen = awful.screen.focused()
					  local tag = screen.tags[i]
					  if tag then
						 awful.tag.viewtoggle(tag)
					  end
				  end,
				  {description = 'toggle tag #' .. i, group = 'tag'}),
		-- Move client to tag.
		awful.key({ modkey, 'Shift' }, '#' .. i + 9,
				  function ()
					  if client.focus then
						  local tag = client.focus.screen.tags[i]
						  if tag then
							  client.focus:move_to_tag(tag)
						  end
					 end
				  end,
				  {description = 'move focused client to tag #'..i, group = 'tag'}),
		-- Toggle tag on focused client.
		awful.key({ modkey, 'Control', 'Shift' }, '#' .. i + 9,
				  function ()
					  if client.focus then
						  local tag = client.focus.screen.tags[i]
						  if tag then
							  client.focus:toggle_tag(tag)
						  end
					  end
				  end,
				  {description = 'toggle focused client on tag #' .. i, group = 'tag'})
	)
end

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the 'manage' signal).
awful.rules.rules = require('rules')
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal('manage', function (c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup
	  and not c.size_hints.user_position
	  and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
local get_titlebars = require('titlebars')
get_titlebars()

-- Enable sloppy focus, so that focus follows mouse and show the
-- volume widget on the correct screen.
client.connect_signal('mouse::enter', function(c)
	c:emit_signal('request::activate', 'mouse_enter', {raise = false})
end)

client.connect_signal('focus', function(c)
	c.border_color = beautiful.border_focus
	client.emit_signal('request::titlebars', c)
end)
client.connect_signal('unfocus', function(c)
	c.border_color = beautiful.border_normal
	client.emit_signal('request::titlebars', c)
end)
-- }}}

-- Add shadows to floating windows
--local true_useless_gap = beautiful.useless_gap
--local orig_client_size = {}
screen.connect_signal('arrange', function (s)
	local layout = s.selected_tag.layout.name
	local is_single_client = #s.clients == 1
	--[[
	for _, c in pairs(s.clients) do
		beautiful.useless_gap = true_useless_gap
		if (layout == 'floating' or layout == 'max') then
			beautiful.useless_gap = 0
		end
	end
	--]]

	for _, c in pairs(s.clients) do
		--[[
		if not c.borderless then
			naughty.notify { text = tostring(c)..' is borderless' }
			awful.titlebar.hide(c, 'top')
			awful.titlebar.hide(c, 'right')
			awful.titlebar.hide(c, 'left')
			awful.titlebar.hide(c, 'bottom')
		end
		--]]

		if (layout == 'floating' or c.floating and not c.maximized) then
			-- show borders and titlebars
			if (not c.borderless) then
				c.top_titlebar = awful.titlebar(c, {
					size           = (beautiful.titlebar_size or dpi(28)) + (beautiful.border_width or dpi(2)),
					enable_tooltip = false,
					position       = 'top',
					bg             = '#00000030', -- transparency; may conflict with transparent titlebars by darkening them, but this makes shadows basically seamless.
				})
			else
				awful.titlebar.hide(c, 'top')
				awful.titlebar.hide(c, 'right')
				awful.titlebar.hide(c, 'left')
				awful.titlebar.hide(c, 'bottom')
			end

   			awful.spawn('xprop -id ' .. c.window .. ' -f _COMPTON_SHADOW 32c -set _COMPTON_SHADOW 1', false)
			c.shape = function(cr,w,h)
				gears.shape.partially_rounded_rect(cr,w,h, true, true, false, false, ((beautiful.titlebar_radius or dpi(20)) - dpi(8)))
			end
		else
			-- show only borders
			if (not c.borderless) then
				c.top_titlebar = awful.titlebar(c, {
					size           = beautiful.border_width or dpi(2),
					enable_tooltip = false,
					position       = 'top',
					bg             = '#00000030', -- transparency; may conflict with transparent titlebars by darkening them, but this makes shadows basically seamless.
				})
			else
				awful.titlebar.hide(c, 'top')
				awful.titlebar.hide(c, 'right')
				awful.titlebar.hide(c, 'left')
				awful.titlebar.hide(c, 'bottom')
			end

			awful.spawn('xprop -id ' .. c.window .. ' -f _COMPTON_SHADOW 32c -set _COMPTON_SHADOW 0', false)
			c.shape = gears.shape.square
		end
	end
end)

-- Autostart
awful.spawn.with_shell(os.getenv('HOME') .. '/.screenlayout/layout.sh')
awful.spawn.with_shell(config_dir .. '/scripts/autostart.sh')

----------------------------------------------------------------------------------------

--[ [
client.connect_signal('manage', function(c)
	if not c.floating then
		c.floating_width  = c.width
		c.floating_height = c.height
		c.floating_x      = c.x
		c.floating_y      = c.y
	end

	c:connect_signal('property::floating', function()
		if c.floating then
			c:set_width ( ((c.floating_width  or c.width ) - (beautiful.border_width or 0)) + dpi(2) )
			c:set_height( ((c.floating_height or c.height) - ( (beautiful.titlebar_size or dpi(28)) + (beautiful.border_width or 0))) + dpi(4) )
			c:set_x(c.floating_x or c.x)
			c:set_y(c.floating_y or c.y)
		else
			c.floating_width  = c.width
			c.floating_height = c.height
			c.floating_x      = c.x
			c.floating_y      = c.y
		end
	end)
end) --]]

--[[
local testbox = wibox {
	type    = 'utility',
	bg      = '#00000000',
	screen  = screen.primary,
	shape   = gears.shape.circle,
	visible = true,
	ontop   = true,
	width   = 100,
	height  = 100,
}

local testbox_widget = wibox.widget {
	{
		text   = '',
		widget = wibox.widget.textbox
	},
	shape  = gears.shape.circle,
	bg     = '#FFFFFF',
	widget = wibox.container.background,
}

testbox:setup {
	{
		testbox_widget,
		layout = wibox.layout.flex.horizontal,
	},
	margins = dpi(8),
	widget  = wibox.widget.margin,
	layout  = wibox.layout.flex.vertical,
}

awful.placement.centered(testbox)

local testbox_bg_hue = 0
gears.timer {
	timeout   = 0.01,
	autostart = true,
	callback  = function()
		if testbox_bg_hue >= 1 then testbox_bg_hue = 0 end
		testbox_widget:set_bg(hsl(testbox_bg_hue, 1, 0.5))
		testbox_bg_hue = testbox_bg_hue + 0.01
		--naughty.notify({ text = tostring(hsl(testbox_bg_hue, 1, 0.5)) })
	end
}
--]]

--[[
testwibox = wibox {
	bg      = '#0000',
	width   = dpi(300),
	height  = dpi(300),
	type    = 'utility',
	screen  = 'primary',
	visible = true,
	ontop   = true,
}

awful.placement.bottom_left(testwibox)

testwidget = wibox.widget {
	{
		text   = 'Hello',
		align  = 'center',
		valign = 'center',
		widget = wibox.widget.textbox,
	},
	bg                 = beautiful.nord0,
	shape              = rounded_rectangle(dpi(20)),
	shape_border_width = dpi(1),
	shape_border_color = beautiful.nord4,
	widget             = wibox.container.background,
}

function add_shadow(widget, size, radius, layerdist)
	size      = size      or 10
	radius    = radius    or dpi(20)
	layerdist = layerdist or 1

	for i=1, size do
		widget = wibox.widget {
			{
				widget,
				margins = layerdist,
				widget  = wibox.container.margin,
			},
			bg     = '#00000004',
			shape  = rounded_rectangle(radius),
			widget = wibox.container.background,
		}
	end

	return(widget)
end

testwidget = add_shadow(testwidget, 20, dpi(20), 1)

testwibox:setup {
	nil,
	{
		testwidget,
		margins = dpi(10),
		widget  = wibox.container.margin,
	},
	layout = wibox.layout.align.vertical,
}
--]]