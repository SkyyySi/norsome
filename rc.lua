----------------------------------------------------------------------------------------------------
--                                       Initialize awesome                                       --
----------------------------------------------------------------------------------------------------

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Awesome librarys
gears         = require("gears")
awful         = require("awful")
wibox         = require("wibox")
beautiful     = require("beautiful")
naughty       = require("naughty")
menubar       = require("menubar")
hotkeys_popup = require("awful.hotkeys_popup")
--archmenu      = require("archmenu")
require("awful.autofocus")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Wibar does not allow for changing which bar is shown first. This is
-- a modified version of the code that takes care of the bar order.
awfulwibar = require("awfulwibar")

-- Autostart applications
awful.spawn(awful.util.getdir("config") .. '/autostart.sh')


-- Error handling
dofile(awful.util.getdir("config") .. "config/error-handler.lua")

-- {{{ Variable definitions
theme       = 'nord'
terminal    = 'alacritty'
webbrowser  = 'firefox'
filemanager = 'pcmanfm'
editor      = 'code'
editor_cmd  = editor
config_dir  = awful.util.getdir('config')
themes_dir  = config_dir .. 'themes/'
theme_dir   = themes_dir .. theme

-- Themes define colours, icons, font and wallpapers.
beautiful.init(theme_dir .. "/theme.lua")

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.spiral,
    awful.layout.suit.floating,
    awful.layout.suit.max,
--[[
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
--awful.spawn.with_shell("xdg_menu --format awesome --root-menu /etc/xdg/menus/arch-applications.menu > ~/.config/awesome/archmenu.lua")

-- Create a launcher widget and a main menu
local menu_awesome = {
    { "Show hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "Show manual", terminal .. " -e man awesome" },
--    { "Edit config", editor_cmd .. " " .. awesome.conffile },
    { "Edit config", editor_cmd .. " " .. config_dir },
    { "Restart awesome", awesome.restart },
    { "Quit awesome", function() awesome.quit() end },
}

local menu_power = {
    { "Lock session", "loginctl  lock-session" },
    { "Shutdown",     "systemctl shutdown" },
    { "Reboot",       "systemctl reboot" },
    { "Suspend",      "systemctl suspend" },
    { "Hibernate",    "systemctl hibernate" },
}

local awesome_menu = awful.menu({ items = { { "Awesome", menu_awesome, beautiful.awesome_icon },
                                       { "Power", menu_power },
--                                       { "Applications", xdgmenu },
                                       { "––––––––––––––––––––" },
                                       { "Terminal", terminal },
                                       { "Web browser", webbrowser },
                                       { "File manager", filemanager },
                                  } })

local rounded_rectangle = require("rounded_rectangle")
local rounded_wibox     = require("rounded_wibox")

----------------------------------------------------------------------------------------------------------------------------------
-- Closable wibox
----------------------------------------------------------------------------------------------------------------------------------
--[[
local animWibox = wibox {
    bg      = '#347653',
    width   = 100,
    height  = 100,
    visible = true,
    ontop   = true,
}
awful.placement.bottom_right(animWibox, { margins = {bottom = 50, right = 50}, parent = awful.screen.focused()})

local animWiboxButton = wibox.widget {
    {
        {
            text = "Button",
            widget = wibox.widget.textbox,
        },
        margins = 4,
        widget  = wibox.container.margin,
    },
    bg                 = '#00000080',
    shape              = rounded_rectangle(10),
    shape_border_width = 1,
    shape_border_color = '#AAEEFF',
    widget             = wibox.container.background,
}

animWiboxButton:connect_signal("mouse::enter",    function(c) c:set_bg('#40404080') end)
animWiboxButton:connect_signal("mouse::leave",    function(c) c:set_bg('#00000080') end)
animWiboxButton:connect_signal("button::press",   function(c) c:set_bg('#80808080') end)
animWiboxButton:connect_signal("button::release", function(c) c:set_bg('#40404080') end)

local opacity = 0.1
local animWiboxCircle = wibox.widget {
    {
        widget = wibox.widget.textbox(' ')
    },
    bg                 = '#0000',
    shape              = gears.shape.circle,
    shape_border_width = 2,
    shape_border_color = '#FFFFFF',
    widget             = wibox.container.background,
    opacity            = opacity
}

animWibox:setup {
    {
        animWiboxButton,
        animWiboxCircle,
        layout = wibox.layout.align.vertical,
    },
    widget = wibox.container.background,
    valigh = 'center',
    layout = wibox.container.place
}

animWiboxButton:connect_signal("button::press", function(c, _, _, button)
    if button == 1 then
        gears.timer {
            timeout   = 4,
            call_now  = true,
            autostart = true,
            callback  = function()
                local range
                for range=0,10 do
                    local i = range / 10
                    animWiboxCircle.opacity = i
                    animWiboxCircle:emit_signal("widget::redraw_needed")
                end
            end
        }
    end
end) --]]

--[[
local makeCloseButton
function makeCloseButton(args)
    local bg_normal = args.bg_normal or '#00000080'
    local bg_select = args.bg_select or '#80808080'
    local s         = args.scale     or 100
    local scale     = s / 5

    local close_button = wibox.widget {
        {
            {
                image  = '/home/simon/Dokumente/svg/close.svg',
                resize = true,
                widget = wibox.widget.imagebox,
            },
            margins = scale,
            widget  = wibox.container.margin,
        },
        bg     = bg_normal,
        shape  = gears.shape.circle,
        widget = wibox.container.background,
    }

    close_button:connect_signal("mouse::enter", function(c)
        c:set_bg(bg_select)
    end)
    close_button:connect_signal("mouse::leave", function(c)
        c:set_bg(bg_normal)
    end)

    close_button:connect_signal("button::release", function(c, _, _, button)
        if button == 1 then
            naughty.notify{text = 'Left click'}

        elseif button == 2 then
            naughty.notify{text = 'Wheel click'}

        elseif button == 3 then
            naughty.notify{text = 'Right click'}
        end
    end)

    return close_button
end

local testbox = wibox {
    width   = 30,
    height  = 30,
    visible = true,
    ontop   = true,
    shape   = rounded_rectangle(17),
}

testbox:setup {
    {
        {
            makeCloseButton({scale = 30}),
            layout = wibox.layout.stack,
        },
        width         = 50,
        height        = 50,
        forced_width  = 50,
        forced_height = 50,
        strategy      = 'min',
        widget        = wibox.container.constraint,
        layout        = wibox.layout.stack,
    },
    layout = wibox.layout.stack,
    shape  = rounded_rectangle(18),
    bg     = '#0000',
    widget = wibox.container.background,
}

local fullbox = wibox {
    bg      = '#202020',
    width   = 400,
    height  = 300,
    visible = true,
--    ontop   = true,
    shape   = rounded_rectangle(17),
}

fullbox:setup {
    {
        widget = testbox,
        layout = wibox.layout.align.horizontal,
    },
    shape  = rounded_rectangle(18),
    bg     = '#202020',
    widget = wibox.container.background,
}

awful.placement.bottom_right(fullbox, { margins = {bottom = 50, right = 50}, parent = awful.screen.focused()})
awful.placement.bottom_right(testbox, { margins = {bottom = 310, right = 60}, parent = awful.screen.focused()}) --]]

----------------------------------------------------------------------------------------------------------------------------------
-- Closable wibox end
----------------------------------------------------------------------------------------------------------------------------------

local menubutton = require("menubutton")

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()
local kbdlayout = wibox.widget {
    {
        {
            mykeyboardlayout,
            layout = wibox.layout.align.horizontal,
        },
        bg     = '#3b4252',
        widget = wibox.container.background,
        layout = wibox.layout.align.horizontal,
        shape  = rounded_rectangle(20),
    },
    margins            = 4,
    shape_border_width = 1,
    shape_border_color = '#d8dee9',
    widget             = wibox.container.margin,
    layout             = wibox.layout.align.horizontal,
}

-- {{{ Dock
local awedock
function awedock(arg)
    local position = arg.position or 'bottom'
    local height   = arg.size or 64
    local width    = height
    local widgets  = arg.widgets
    for i, v in pairs(widgets) do width = width + height end
    width = width - height
    widgets['layout'] = wibox.layout.fixed.horizontal

    local awedock_aa_box = awfulwibar {
        bg       = '#0000',
        type     = 'desktop',
        width    = width,
        height   = height,
        ontop    = true,
        visible  = true,
        stretch  = false,
        position = 'bottom',
        --layout   = wibox.layout.flex.horizontal,
    }

    local cly = client.focus
    local icon_widget = wibox.widget {
        {
            {
                {
                    --image  = awful.widget.clienticon(cly),
                    image  = beautiful.awesome_icon,
                    resize = true,
                    widget = wibox.widget.imagebox,
                },
                margins = 2,
                widget  = wibox.container.margin,
            },
            bg     = '#FFFFFF40',
            shape  = rounded_rectangle(5),
            widget = wibox.container.background,
        },
        margins = 4,
        widget  = wibox.container.margin,
    }

    local dockwidget = {}
    dockwidget.menu = wibox.widget {
        {
            icon_widget,
            layout = wibox.layout.align.horizontal,
        },
        margins = 2,
        widget  = wibox.container.margin,
    }

    local awedock
    awedock = wibox.widget {
        {
            color        = '#00000080',
            orientation  = 'horizontal',
            thickness    = 50,
            forced_width = 40,
            widget       = wibox.widget.separator,
            shape        = rounded_rectangle(10),
        },
        width    = width,
        height   = height,
        strategy = 'exact',
        widget   = wibox.container.constraint,
    }

    awedock_aa_box:setup {
        layout = wibox.layout.align.horizontal,
        {
            {
                layout = wibox.layout.fixed.horizontal,
                awedock
            },
            {
                {
                    layout = wibox.layout.fixed.horizontal,
                    widgets,
                },
                margins = 4,
                widget  = wibox.container.margin,
            },
            layout = wibox.layout.stack,
        },
    }

    return(awedock_aa_box)
end

local icon_widget = wibox.widget {
    {
        {
            {
                --image  = awful.widget.clienticon(cly),
                image  = beautiful.awesome_icon,
                resize = true,
                widget = wibox.widget.imagebox,
            },
            margins = 2,
            widget  = wibox.container.margin,
        },
        bg     = '#FFFFFF40',
        shape  = rounded_rectangle(5),
        widget = wibox.container.background,
    },
    margins = 4,
    widget  = wibox.container.margin,
}

local dockwidget
function dockwidget(c)
    local widget = wibox.widget {
        {
            {
                icon_widget,
                layout = wibox.layout.align.horizontal,
            },
            margins = 2,
            widget  = wibox.container.margin,
        },
        bg     = c or 'red',
        widget = wibox.container.background,
    }

    return(widget)
end

--dock = awedock({
--    size     = 80,
--    position = 'bottom',
--    widgets  = {
--        dockwidget('red'),
--        dockwidget('green'),
--        dockwidget('blue'),
--        --layout = wibox.layout.fixed.horizontal,
--    }
--})

--awful.placement.bottom(dock, { margins = { bottom = 5 }, parent = awful.screen.focused()})
-- }}}


-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                {raise = true}
            )
        end
    end),

    awful.button({ }, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),

    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
    end),

    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
    end)
)

local function set_wallpaper(s)
    -- Wallpaper
    --awful.spawn("nitrogen --restore")
    awful.spawn("hsetroot -add '#2e3440' -add '#eceff4' -gradient 180")
end

local volume_button = require('modules.widgets.volume')

--- CALENDAR ---
local calendar_widget = require('modules.widgets.calendar')

--- CONTROL PANEL ---
local control_panel_widget
function control_panel_widget(s)
    --local xresources = require("beautiful.xresources")
    --local dpi        = xresources.apply_dpi

    s.widget_volume_icon   = wibox.widget {
        {
            font   = 'Source Code Pro 16',
            text   = ' 🔊 ',
            widget = wibox.widget.textbox,
        },
        bg     = '#444444',
        shape  = rounded_rectangle(20),
        widget = wibox.container.background,
    }

    local volume_slider = wibox.widget {
        bar_shape           = gears.shape.rounded_rect,
        bar_height          = 4,
        bar_color           = '#88c0d0',
        handle_color        = '#81a1c1',
        handle_shape        = gears.shape.circle,
        handle_border_color = '#eceff4',
        handle_border_width = 2,
        value               = 50,
        minimum             = 0,
        maximum             = 100,
        widget              = wibox.widget.slider,
    }

    s.widget_volume_slider = wibox.widget {
        {
            {
                {
                    volume_slider,
                    layout = wibox.layout.align.horizontal,
                },
                left   = 15,
                right  = 15,
                widget = wibox.container.margin,
            },
            bg     = '#555555',
            shape  = rounded_rectangle(999),
            widget = wibox.container.background,
        },
        strategy = 'exact',
        width    = 300,
        height   = 60,
        widget = wibox.container.constraint
    }

    local old_cursor, old_wibox
    volume_slider:connect_signal("mouse::enter", function(c)
        c:set_handle_color('#88c0d0') -- hovered / nord 3
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand1"
    end)
    volume_slider:connect_signal("mouse::leave", function(c)
        c:set_handle_color('#81a1c1') -- default / nord 2
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    volume_slider:connect_signal("button::press",   function(c)
        if button == 1 then
            c:set_handle_color('#5e81ac') -- pressed  / nord 4
        end
    end)
    volume_slider:connect_signal("button::release", function(c) c:set_handle_color('#81a1c1') end) -- released / nord 3

    s.control_panel = awfulwibar {
        bg       = '#222',
        position = 'right',
        stretch  = true,
        visible  = false,
        ontop    = true,
        screen   = s,
        width    = 400,
        layout = wibox.layout.flex.vertical,
    }

    s.control_panel:setup {
        direction = "east",
        layout    = wibox.layout.align.vertical,
        --[[{
            s.widget_volume_icon,
            layout = wibox.layout.fixed.vertical,
        },
        {
            s.widget_volume_icon,
            layout = wibox.layout.flex.vertical,
        },--]]
        {
            {
                {
                    --[[{
                        s.widget_volume_icon,
                        layout = wibox.layout.fixed.horizontal,
                    },--]]
                    {
                        nil,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    {
                        s.widget_volume_slider,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    {
                        nil,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    bg     = '#606060',
                    widget = wibox.container.background,
                    layout = wibox.layout.align.horizontal,
                },
                layout = wibox.layout.fixed.horizontal,
            },
        margins = 10,
        widget  = wibox.container.margin,
        },
    }

    s.control_panel_button = wibox.widget{
        {{{
                    font = 'Source Code Pro Black 22',
                    text = '◀',
                    widget = wibox.widget.textbox,
                },
                top = 4, bottom = 4, left = 8, right = 8,
                widget = wibox.container.margin,
            },
            bg = '#3b4252',
            shape_border_width = 1,
            shape_border_color = '#d8dee9',
            shape = rounded_rectangle(20),
            widget = wibox.container.background,
        },
        margins = 4,
        widget = wibox.container.margin,
    }

    if s.control_panel.visible == true then
        s.control_panel_button.widget.widget.widget.text = '▶'
    else
        s.control_panel_button.widget.widget.widget.text = '◀'
    end

    local old_cursor, old_wibox
    s.control_panel_button.widget:connect_signal("mouse::enter", function(c)
        c:set_bg('#434c5e') -- hovered  / nord 2
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand1"
    end)
    s.control_panel_button.widget:connect_signal("mouse::leave", function(c)
        c:set_bg('#3b4252') -- default  / nord 1
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    s.control_panel_button.widget:connect_signal("button::press",   function(c) c:set_bg('#4c566a') end) -- pressed  / nord 3
    s.control_panel_button.widget:connect_signal("button::release", function(c)
        c:set_bg('#434c5e') -- released / nord 2
        if s.control_panel.visible == false then
            s.control_panel.visible = true
            s.control_panel_button.widget.widget.widget.text = '▶'
        else
            s.control_panel.visible = false
            s.control_panel_button.widget.widget.widget.text = '◀'
        end
    end)

    return(s.control_panel_button)
end

--control_panel_widget = require('modules.widgets.control_panel')

--- TAGLIST ---
local awidget = {}
function awidget.taglist(s)
    local taglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,

        style  = {
            shape = rounded_rectangle(8),
            font  = "Source Code Pro black 16"
        },
    }

    return(taglist)
end

--- TASKLIST ---
function awidget.tasklist(s)
    local tasklist = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = tasklist_buttons,
        layout   = {
            --spacing_widget = {
            --    {
            --        forced_width  = 5,
            --        forced_height = 24,
            --        thickness     = 1,
            --        color         = '#000',
            --        widget        = wibox.widget.separator
            --    },
            --    valign = 'center',
            --    halign = 'center',
            --    widget = wibox.container.place,
            --},
            --spacing = 10,
            layout  = wibox.layout.fixed.horizontal
        },
        -- Notice that there is *NO* wibox.wibox prefix, it is a template,
        -- not a widget instance.
        widget_template = {
            {
                {
                    {
                        {
                            {
                                id     = 'clienticon',
                                widget = awful.widget.clienticon,
                            },
                            left   = 10,
                            right  = 10,
                            top    = 4,
                            bottom = 4,
                            widget = wibox.container.margin,
                        },
                        --wibox.widget.base.make_widget(),
                        id     = 'background_role',
                        shape  = rounded_rectangle(20),
                        widget = wibox.container.background,
                    },
                    shape              = rounded_rectangle(20),
                    shape_border_width = 1,
                    shape_border_color = '#d8dee9',
                    widget             = wibox.container.background,
                },
                margins = 4,
                widget  = wibox.container.margin,
            },
            nil,
            create_callback = function(self, c, index, objects) --luacheck: no unused args
                self:get_children_by_id('clienticon')[1].client = c
            end,
            layout = wibox.layout.align.vertical,
        },
    }

    return(tasklist)
end

--- SYSTEM TRAY ---

local bar_spacer = wibox.widget {
    color        = '#0000',
    span_ratio   = 0.9,
    visible      = true,
    forced_width = 10,
    widget       = wibox.widget.separator
}

local systray_placed = false
local systray = wibox.widget{
    {{{{
                    set_horizontal = true,
                    set_base_size  = 22,
                    forced_height  = 20,
                    widget         = wibox.widget.systray(false),
                },
                left = 20, right = 20, top = 3,
                widget = wibox.container.margin,
            },
            layout = wibox.layout.flex.horizontal,
        },
        bg                 = '#4C566A',
        shape_border_color = '#d8dee9',
        shape_border_width = 1,
        shape              = rounded_rectangle(20),
        widget             = wibox.container.background,
    },
    margins = 4,
    widget  = wibox.container.margin,
}

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ ' 1 ', ' 2 ', ' 3 ', ' 4 ', ' 5 ', ' 6 ', ' 7 ', ' 8 ', ' 9 ', }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
--[[    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    } ]]--
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		layout = wibox.layout.fixed.vertical,
		buttons = taglist_buttons,
		style = {
			font = "Source Code Pro black 20"
		},
		widget_template = {
		{
			id     = 'text_role',
			align  = "center",
			widget = wibox.widget.textbox,
		},
		id     = 'background_role',
		widget = wibox.container.background,
	        -- Add support for hover colors and an index label
		create_callback = function(self, c3, index, objects) --luacheck: no unused args
			self:connect_signal('mouse::press', function()
				bg = darkblue
			end)
		end,

		},
	}

    -- Create a tasklist widget
--[[   s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    } ]]--
    s.mytasklist = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = tasklist_buttons,
        style    = {
            shape_border_width = 1,
            shape_border_color = '#d8dee9',
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 20)
            end,
        },
        layout   = {
            spacing = 5,
            spacing_widget = {
--[[                {
                    forced_width = 5,
                    shape        = gears.shape.circle,
                    widget       = wibox.widget.separator
                }, ]]--
                valign = 'center',
                halign = 'center',
                widget = wibox.container.place,
            },
            layout  = wibox.layout.flex.horizontal
        },
        -- Notice that there is *NO* wibox.wibox prefix, it is a template,
        -- not a widget instance.
        widget_template = {
            {
                {
                    {
                        {
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        margins = 2,
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left  = 10,
                right = 10,
                widget = wibox.container.margin
            },
            id     = 'background_role',
            widget = wibox.container.background,
        },
        margins = 4,
        widget  = wibox.container.margin
    }

    -- Create the top wibar
    s.topwibar   = awfulwibar({
        position = "top",
        stretch  = true,
        screen   = s,
        height   = 40
    })

    -- Create the left wibar
    --s.leftwibar  = awfulwibar({
    --    position = "left",
    --    stretch  = true,
    --    screen   = s,
    --    width    = 48
    --})

    local textclock = wibox.widget.textclock('<span font="Source Sans Pro bold 11">  %H:%M</span>')

    local local_systray
    function local_systray()
        if not systray_placed then
            systray_placed = true
            return systray
        else
            return nil
        end
    end

    s.kbdlayout = kbdlayout

    -- Add widgets to the top wibar
    s.topwibar:setup {
        direction = "east",
        layout    = wibox.layout.align.horizontal,
        {
            menubutton(s),
            awidget.tasklist(s),
            --s.mytasklist,
            --mylauncher,
            s.mypromptbox,
            margins = 4,
            widget  = wibox.container.margin,
            layout  = wibox.layout.align.horizontal,
        },
        {
            layout = wibox.layout.align.horizontal,
        },
        {
--            awful.titlebar.widget.closebutton(c),
            awidget.taglist(s),
            s.kbdlayout,
            volume_button,
            calendar_widget(s),
            control_panel_widget(s),
            local_systray(),
            s.mylayoutbox,
            layout = wibox.layout.fixed.horizontal,
        },
    }

    -- Add widgets to the left wibar
    --s.leftwibar:setup {
    --    direction = "east",
    --    layout    = wibox.layout.align.vertical,
    --    { -- Left widgets
    --        layout = wibox.layout.fixed.vertical,
    --        --menubutton(s),
    --        --s.mytaglist,
    --    },
    --    {
--  --          s.mytasklist, -- Middle widget
    --        widget  = wibox.widget.separator,
    --        visible = false
    --    },
    --    { -- Right widgets
    --        layout = wibox.layout.fixed.vertical,
    --        textclock,
    --        --s.mylayoutbox,
    --    },
    --}
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () awesome_menu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Up",     awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Donw",   awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "Right",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "Left",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn(webbrowser) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "e", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "   Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Shift"   }, "f",      awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
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
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer",
          "Wrapper-2.0",
          "Audacity"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = { type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Hide titlebars and borders from bars and launchers
    { rule_any = { class = {
      "Wrapper-2.0",
      "Ulauncher",
      "Xfce4-panel"
      } },
      properties = {
        titlebars_enabled = false,
        border_width = 0
      }
    },

    -- Fix a wierd bug where Firefox doesn't want to tile
    { rule = { class = "firefox" },
      properties = { opacity = 1, maximized = false, floating = false }
    },

    { rule = { class = "portal2_linux" },
      properties = { opacity = 1, maximized = false, floating = true, titlebars_enabled = false }
    },

    { rule = { class = "Gnome-flashback" },
      properties = { sticky = true, border_width = 0 }
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
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
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            --awful.titlebar.widget.stickybutton   (c),
            --awful.titlebar.widget.ontopbutton    (c),
            --awful.titlebar.widget.minimizebutton (c),
            --awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        shape = rounded_rectangle(20);
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse and show the
-- volume widget on the correct screen.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})

--    if calendar.visible == false then
--        awful.placement.top_right(calendar, { margins = {top = 48, right = 16}, parent = awful.screen.focused()})
--    end
end)

client.connect_signal("focus", function(c)   c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Autostart
--dofile(awful.util.getdir("config") .. "config/autostart.lua")
--awful.spawn("hsetroot -add '#2e3440' -add '#eceff4' -gradient 180")
awful.spawn('nitrogen --restore')
awful.spawn.with_shell('picom --config ' .. config_dir .. '/other/picom/picom.conf&')
--naughty.notify { text = autostart }

----------------------------------------------------------------------------------------
