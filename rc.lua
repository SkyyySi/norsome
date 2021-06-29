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
xdg_menu      = require('archmenu')

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
local night_mode = true

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
awful.layout.layouts = {
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
}
-- }}}

-- {{{ Menu
-- Generate an xdg app menu
awful.spawn.with_shell('xdg_menu --format awesome --root-menu /etc/xdg/menus/arch-applications.menu > ' .. config_dir .. '/archmenu.lua')

-- Create a launcher widget and a main menu
local menu_awesome = {
    { 'Show hotkeys', function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { 'Show manual', terminal .. ' -e man awesome' },
--    { 'Edit config', editor_cmd .. ' ' .. awesome.conffile },
    { 'Edit config', editor_cmd .. ' ' .. config_dir },
    { 'Restart awesome', awesome.restart },
    { 'Quit awesome', function() awesome.quit() end },
}

local menu_power = {
    { 'Lock session', 'loginctl lock-session' },
    { 'Shutdown',     'sudo poweroff'         },
    { 'Reboot',       'sudo reboot'           },
    { 'Suspend',      'systemctl suspend'     },
    { 'Hibernate',    'systemctl hibernate'   },
}

awesome_menu = awful.menu {
    items = {
        { 'Awesome',      menu_awesome, beautiful.awesome_icon  },
        { 'Power',        menu_power,   beautiful.icon.power    },
        { 'Applications', xdgmenu,      beautiful.icon.app      },
        { '––––––––––––––––––––'                                },
        { 'Terminal',     terminal,     beautiful.icon.terminal },
        { 'File manager', filemanager,  beautiful.icon.folder   },
        { 'Web browser',  webbrowser,   beautiful.icon.web      },
    },
    shape = gears.shape.rounded_rect
}

--- EXTERNAL FILES ---
local qrlinux  = {}
qrlinux.widget = {}

-- Signals
require('signals.get_volume')
require('signals.get_song')

-- Modules
local rounded_rectangle = require('rounded_rectangle')
local infobubble        = require('infobubble')
local rounded_wibox     = require('rounded_wibox')
local buttonify         = require('buttonify')
local hsl               = require('hsl')

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
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
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

    --[[ if night_mode then
        s.night_mode = require('night_mode')
        local night_mode_button_wibox = wibox {
            screen  = s,
            type    = 'utility',
            width   = 100,
            height  = 60,
            opacity = 1,
            ontop   = true,
            visible = true,
        }

        local night_mode_button = wibox.widget {
            {
                {
                    {
                        widget = wibox.widget.textbox,
                        text   = 'Night mode!',
                    },
                    widget  = wibox.container.margin,
                    margins = dpi(4),
                },
                widget             = wibox.container.background,
                bg                 = beautiful.button_normal,
                shape              = gears.shape.rounded_bar,
                shape_border_width = 2,
                shape_border_color = beautiful.nord12,
            },
            widget  = wibox.container.margin,
            margins = dpi(4),
        }
        buttonify({ widget = night_mode_button.widget })

        night_mode_button_wibox:setup {
            night_mode_button,
            layout = wibox.layout.align.horizontal
        }

        s.night_mode_overlay = wibox {
            screen            = s,
            width             = 1920,
            height            = 1080,
            type              = 'utility',
            bg                = '#632b00',
            opacity           = 0.0,
            input_passthrough = true,
            ontop             = true,
            visible           = true,
        }
        s.night_mode_overlay_enabled = false
        s.night_mode_overlay_timer = nil

        function s.night_mode_overlay_fade(t)
            s.night_mode_overlay_enabled = t
            if (s.night_mode_overlay_timer) then s.night_mode_overlay_timer:stop() end
            if (t == true) then
                s.night_mode_overlay_timer = gears.timer {
                    timeout = 0.05,
                    call_now = true,
                    autostart = true,
                    callback = function()
                        if (s.night_mode_overlay.opacity < 0.5) then
                            s.night_mode_overlay.opacity = (s.night_mode_overlay.opacity + 0.01)
                        end
                    end
                }
            elseif (t == false) then
                s.night_mode_overlay_timer = gears.timer {
                    timeout = 0.05,
                    call_now = true,
                    autostart = true,
                    callback = function()
                        if (s.night_mode_overlay.opacity > 0) then
                            s.night_mode_overlay.opacity = (s.night_mode_overlay.opacity - 0.01)
                        end
                    end
                }
        end
        gears.timer {
                timeout = 1,
                call_now = true,
                autostart = true,
                callback = function()
                    naughty.notify {text=tostring(s.night_mode_overlay_enabled)}
                end
        }
    end ]]

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
    s.topwibar:setup {
        direction = 'east',
        layout    = wibox.layout.align.horizontal,
        {
            qrwidget.menubutton(s),
            qrwidget.tasklist(s),
            s.promptbox,
            margins = dpi(4),
            widget  = wibox.container.margin,
            layout  = wibox.layout.align.horizontal,
        },
        {
			--myfirstwidget(s),
            --qrwidget.night_mode(s, '#854b11'),
            layout = wibox.layout.fixed.horizontal,
        },
        {
            --qrwidget.music(s),
            --qrwidget.volume(s),
            --qrwidget.wallpaper_select(s, {}), -- Disabled for now.
            qrwidget.taglist(s),
            qrwidget.kbdlayout(s),
            qrwidget.calendar(s),
            qrwidget.systray(screen.primary),
            qrwidget.control_panel(s),
            qrwidget.current_layout(s),
            layout = wibox.layout.fixed.horizontal,
        },
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
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = 0,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          'DTA',  -- Firefox addon DownThemAll.
          'copyq',  -- Includes session name in class.
          'pinentry',
        },
        class = {
            'Arandr',
            'Blueman-manager',
            'Gcr-prompter',
            'Gpick',
            'Kruler',
            'MessageWin',  -- kalarm.
            'Sxiv',
            'Tor Browser', -- Needs a fixed window size to avoid fingerprinting by screen size.
            'Wpa_gui',
            'veromix',
            'xtightvncviewer',
            'Wrapper-2.0',
            'Audacity',
            'lxqt-config',
            'lxqt-admin-user',
            'Kvantum Manager',
            'System-config-printer.py',
            'org.kde.fancontrol.gui',
            'partitionmanager',
            'sddm-config-editor',
        },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          'Event Tester',  -- xev.
        },
        role = {
          'AlarmWindow',  -- Thunderbird's calendar.
          'ConfigManager',  -- Thunderbird's about:config.
          'pop-up',       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

--    -- Add titlebars to normal clients and dialogs
--    { rule_any = { type = { 'normal', 'dialog' }
--      }, properties = { titlebars_enabled = true }
--    },

    -- Hide titlebars and borders from bars and launchers
    {
        rule_any = {
            class = {
                'Wrapper-2.0',
                'Ulauncher',
                'Xfce4-panel',
            }
        },
        properties = {
            floating          = true,
            titlebars_enabled = false,
            border_width      = 0
        }
    },

    { rule = { class = 'krunner' },
        properties = {
            floating          = true,
            titlebars_enabled = false,
            border_width      = 0
        }
    },

    -- "Fix" a wierd bug where Firefox doesn't want to tile
    { rule = { class = 'firefox' },
      properties = { opacity = 1, maximized = false, floating = false }
    },

    { rule = { class = 'portal2_linux' },
      properties = { opacity = 1, maximized = false, floating = true, titlebars_enabled = false }
    },

    { rule = { class = 'Gnome-flashback' },
      properties = { sticky = true, border_width = 0 }
    },
}
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
client.connect_signal('request::titlebars', function(c)
    local bg_color = beautiful.bg_normal

    if c == client.focus then
        bg_color = beautiful.bg_focus
    end

    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal('request::activate', 'titlebar', {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal('request::activate', 'titlebar', {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    c.top_titlebar = awful.titlebar(c, {
        size           = beautiful.titlebar_size or dpi(28),--beautiful.border_width or dpi(2),--
        enable_tooltip = false,
        position       = 'top',
        bg             = '#00000030', -- transparency; may conflict with transparent titlebars by darkening them, but this makes shadows basically seamless.
    })

    c.top_titlebar:setup {
        {
            {
                {
                    {
                        {
                            { -- Left
                                wibox.widget.separator { forced_width = dpi(6), orientation = 'horizontal', visible = true, opacity = 0 },
                                awful.titlebar.widget.iconwidget(c),
                                awful.titlebar.widget.floatingbutton (c),
                                awful.titlebar.widget.stickybutton   (c),
                                awful.titlebar.widget.ontopbutton    (c),
                                layout  = wibox.layout.fixed.horizontal
                            },
                            { -- Middle
                                { -- Title
                                    align  = 'center',
                                    font   = 'Source Sans Pro bold 12',
                                    widget = awful.titlebar.widget.titlewidget(c)
                                },
                                buttons = buttons,
                                layout  = wibox.layout.flex.horizontal
                            },
                            { -- Right
                                awful.titlebar.widget.minimizebutton (c),
                                awful.titlebar.widget.maximizedbutton(c),
                                awful.titlebar.widget.closebutton    (c),
                                layout = wibox.layout.fixed.horizontal
                            },
                            layout = wibox.layout.align.horizontal
                        },
                        shape = function(cr, width, height)
                            gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, (beautiful.titlebar_radius or dpi(20)))
                        end,
                        bg = bg_color,
                        widget = wibox.container.background
                    },
                    top    = dpi(1),
                    left   = dpi(1),
                    right  = dpi(1),
                    widget = wibox.container.margin
                }, --]]
                shape = function(cr, width, height)
                    gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, (beautiful.titlebar_radius or dpi(20)))
                end,
                bg     = c.border_color,
                widget = wibox.container.background
            },
            top    = (beautiful.border_width / 2) or dpi(1),
            left   = (beautiful.border_width / 2) or dpi(1),
            right  = (beautiful.border_width / 2) or dpi(1),
            widget = wibox.container.margin
        },
        shape = function(cr, width, height)
            gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, (beautiful.titlebar_radius or dpi(20)))
        end,
        bg     = beautiful.border_outer or '#2E3440',
        widget = wibox.container.background
    }

    -- These are your "borders"
    local left_titlebar = awful.titlebar(c, {
        size            = beautiful.border_width or dpi(2),
        enable_tooltip  = false,
        position        = 'left',
        bg              = c.border_color
    })
    left_titlebar:setup {
        {
            {
                bg     = c.border_color,
                widget = wibox.container.background
            },
            left   = (beautiful.border_width / 2) or dpi(1),
            widget = wibox.container.margin
        },
        bg     = beautiful.border_outer or '#2E3440',
        widget = wibox.container.background
    }

    local right_titlebar = awful.titlebar(c, {
        size            = beautiful.border_width or dpi(2),
        enable_tooltip  = false,
        position        = 'right',
        bg              = c.border_color
    })
    right_titlebar:setup {
        {
            {
                bg     = c.border_color,
                widget = wibox.container.background
            },
            right  = (beautiful.border_width / 2) or dpi(1),
            widget = wibox.container.margin
        },
        bg     = beautiful.border_outer or '#2E3440',
        widget = wibox.container.background
    }

    local bottom_titlebar = awful.titlebar(c, {
        size            = beautiful.border_width or dpi(2),
        enable_tooltip  = false,
        position        = 'bottom',
        bg              = c.border_color
    })
    bottom_titlebar:setup {
        {
            {
                bg     = c.border_color,
                widget = wibox.container.background
            },
            bottom = (beautiful.border_width / 2) or dpi(1),
            left   = (beautiful.border_width / 2) or dpi(1),
            right  = (beautiful.border_width / 2) or dpi(1),
            widget = wibox.container.margin
        },
        bg     = beautiful.border_outer or '#2E3440',
        widget = wibox.container.background
    }

    --[[
    local bottom_titlebar = awful.titlebar(c, {
        size           = beautiful.titlebar_size or dpi(28),
        enable_tooltip = false,
        position       = 'bottom',
    })

    bottom_titlebar:setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = 'center',
                font   = 'Source Sans Pro bold 12',
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            --awful.titlebar.widget.minimizebutton (c),
            --awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
    --]]
end)

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
        if layout == 'floating' or c.floating and not c.maximized then
            -- hide x11 borders and show titlebars
            c.top_titlebar = awful.titlebar(c, {
                size           = beautiful.titlebar_size or dpi(28),--beautiful.border_width or dpi(2),--
                enable_tooltip = false,
                position       = 'top',
                bg             = '#00000030', -- transparency; may conflict with transparent titlebars by darkening them, but this makes shadows basically seamless.
            })

   		    awful.spawn('xprop -id ' .. c.window .. ' -f _COMPTON_SHADOW 32c -set _COMPTON_SHADOW 1', false)
            c.shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, ((beautiful.titlebar_radius or dpi(20)) - dpi(8)))
            end
        else
            -- hide titlebars and show x11 borders
            c.top_titlebar = awful.titlebar(c, {
                size           = beautiful.border_width or dpi(2),
                enable_tooltip = false,
                position       = 'top',
                bg             = '#00000030', -- transparency; may conflict with transparent titlebars by darkening them, but this makes shadows basically seamless.
            })

    		awful.spawn('xprop -id ' .. c.window .. ' -f _COMPTON_SHADOW 32c -set _COMPTON_SHADOW 0', false)
            c.shape = gears.shape.square
        end
    end
end)

-- Autostart
awful.spawn.with_shell(os.getenv('HOME') .. '/.screenlayout/layout.sh')
awful.spawn.with_shell(config_dir .. '/scripts/autostart.sh')
--[[
--awful.spawn.with_shell('awesome-client '..'''..'naughty.notify({text = 'It works'})'..''')
--dofile(awful.util.getdir('config') .. 'config/autostart.lua')
--awful.spawn('hsetroot -add '#2e3440' -add '#eceff4' -gradient 180')
--awful.spawn('nitrogen --restore')
--awful.spawn('playerctld daemon')
--awful.spawn('lxqt-session -w 'awesome'')
--awful.spawn('lxqt-powermanagement')
--awful.spawn('lxqt-policykit-agent')
--awful.spawn.with_shell('picom --config ' .. config_dir .. '/other/picom/picom.conf&')
--naughty.notify { text = autostart }
--]]

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
