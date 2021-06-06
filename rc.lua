----------------------------------------------------------------------------------------------------
--                                       Initialize awesome                                       --
----------------------------------------------------------------------------------------------------

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

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
--archmenu      = require('archmenu')
require('awful.autofocus')

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require('awful.hotkeys_popup.keys')

-- Add the local module and widget directory to awesome's path
package.path = package.path .. ';' .. awful.util.getdir('config') .. '/modules/?.lua'

-- Autostart applications
--awful.spawn(awful.util.getdir("config") .. '/scipts/autostart.sh')

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

-- Load bling for extra stuff
bling = require('bling')
bling.signal.playerctl.enable()

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
--

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

-- Widgets
local menubutton        = require('menubutton')

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

local testbox = wibox.widget {
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
}

local fullbox = wibox {
    bg      = '#202020',
    width   = 400,
    height  = 300,
    x       = 1000,
    y       = 1000,
    visible = true,
--    ontop   = true,
    shape   = rounded_rectangle(17),
}

fullbox:setup {
    {
        testbox,
        layout = wibox.layout.align.horizontal,
    },
    shape  = rounded_rectangle(18),
    bg     = '#202020',
    widget = wibox.container.background,
}

fullbox:connect_signal("button::press", function(c, x, y, button)
    if button == 1 then
        --fullbox.x(mouse.coords().x)
        --naughty.notify({text = tostring(mouse.coords().x)})
        --naughty.notify{text = 'X: '..tostring(x)..', Y:'..tostring(y)}
        local coords = fullbox:find_widgets(x, y)
        naughty.notify({text = tostring(coords[x])})
    end
end)

awful.placement.bottom_right(fullbox, { margins = {bottom = 50, right = 50}, parent = awful.screen.focused()})
--awful.placement.bottom_right(testbox, { margins = {bottom = 310, right = 60}, parent = awful.screen.focused()}) --]]

----------------------------------------------------------------------------------------------------------------------------------
-- Closable wibox end
----------------------------------------------------------------------------------------------------------------------------------

--[[
local testbox
function testbox(s)
    s.mainbox = wibox {
        bg      = '#0008',
        type    = 'dnd',
        screen  = s,
        visible = true,
        ontop   = true,
        width   = 150,
        height  = 50,
        shape   = gears.shape.rounded_bar,
    }

    s.mainwidget_bar = wibox.widget {
        min_value        = 1,
        max_value        = 100,
        value            = 0,
        forced_height    = 20,
        forced_width     = 100,
        paddings         = 1,
        color            = beautiful.nord11,
        background_color = beautiful.nord3,
        border_color     = beautiful.border_color,
        border_width     = 1,
        shape            = gears.shape.rounded_bar,
        bar_shape        = gears.shape.rounded_bar,
        widget           = wibox.widget.progressbar,
    }

    s.mainwidget_text = wibox.widget {
        text   = '',
        widget = wibox.widget.textbox,
    }

    --awesome.connect_signal('qrlinux::media::get_song_title', function(t)
	--	s.mainwidget_text:set_text(tostring(t))
	--end)

    s.mainwidget = wibox.widget {
        {
            {
                {
                    s.mainwidget_bar,
                    {
                        s.mainwidget_text,
                        left   = 50,
                        layout = wibox.layout.align.horizontal,
                        widget = wibox.widget.margin,
                    },
                    layout = wibox.layout.stack,
                },
                bg                 = beautiful.nord2,
                shape              = rounded_rectangle(20),
                shape_border_color = beautiful.nord4,
                shape_border_width = 2,
                widget             = wibox.container.background,
            },
            strategy = 'exact',
            height   = 32,
            widget   = wibox.container.constraint,
        },
        margins = 10,
        widget  = wibox.container.margin,
    }

    awesome.connect_signal('qrlinux::media::get_song_prog_percent', function(p)
		s.mainwidget_bar:set_value(p)
	end)

    s.mainbox:setup {
        s.mainwidget,
        layout = wibox.layout.align.vertical,
    }

    return(s.mainbox)
end

awful.placement.bottom_right(testbox(awful.screen.focused()), { margin = { right = 16, bottom = 16 } } ) --]]

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Dock
local awedock
function awedock(arg)
    local screen   = arg.screen   or awful.screen.focused()
    local position = arg.position or 'bottom'
    local height   = arg.size or 64
    local width    = height
    local widgets  = arg.widgets
    local widget_count = 0
    for i, v in pairs(widgets) do widget_count = widget_count + 1 end
    width = width + height * ((widget_count - 1) * 0.9)
    widgets['layout'] = wibox.layout.fixed.horizontal

    local awedock_aa_box = awful.wibar {
        bg       = '#0000',
        type     = 'desktop',
        width    = width,
        height   = height,
        ontop    = true,
        visible  = true,
        stretch  = false,
        screen   = screen,
        position = 'bottom',
        --layout   = wibox.layout.flex.horizontal,
    }

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
        bg     = c or '#FFFFFF00',
        widget = wibox.container.background,
    }

    return(widget)
end

--dock = awedock({
--    size     = 80,
--    position = 'bottom',
--    widgets  = {
--        --menubutton(),
--        --dockwidget(),
--        dockwidget('red'),
--        dockwidget('green'),
--        dockwidget('blue'),
--        dockwidget('magenta'),
--        dockwidget('yellow'),
--        dockwidget('cyan'),
--        --layout = wibox.layout.fixed.horizontal,
--    }
--})
--
--awful.placement.bottom(dock, { margins = { bottom = 5 }, parent = awful.screen.focused()})
-- }}}


-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Wallpaper
local function set_wallpaper(s)
    awful.spawn("nitrogen --restore")
    --awful.spawn("hsetroot -add '#2e3440' -add '#eceff4' -gradient 180")
end

local mediabox = wibox {
    visible = false,
    ontop   = true,
    width   = 200,
    height  = 200,
}

local media = {}

media.buttons = wibox.widget {
    {
        markup = '⏮',
        widget = wibox.widget.textbox,
    },
    {
        markup = '-',
        widget = wibox.widget.textbox,
    },
    {
        markup = '⏭',
        widget = wibox.widget.textbox,
    },
    layout = wibox.layout.align.horizontal,
}

media.buttons:connect_signal('qrlinux::media::get_song_status', function(status)
    if status == true then
        status_text = '⏸'
    else
        status_text = '⏵'
    end

    naughty.notify({text = status_text})
    media.buttons = wibox.widget {
        {
            markup = '⏮',
            widget = wibox.widget.textbox,
        },
        {
            markup = status_text,
            widget = wibox.widget.textbox,
        },
        {
            markup = '⏭',
            widget = wibox.widget.textbox,
        },
        layout = wibox.layout.align.horizontal,
    }

    --media.buttons:emit_signal('widget::redraw_needed')
end)

media.cover = wibox.widget {
    {
        resize     = true,
        image      = '/usr/share/backgrounds/wallpapers/wallpapers/charlotte_day.jpg',
        widget     = wibox.widget.imagebox,
    },
    widget = wibox.container.constraint,
    layout = wibox.layout.align.vertical,
}

awesome.connect_signal('qrlinux::media::get_song_cover', function(cover)
    --naughty.notify({text = 'New cover: ' .. cover})
    media.cover = wibox.widget {
        {
            resize     = true,
            image      = cover,
            widget     = wibox.widget.imagebox
        },
        widget = wibox.container.constraint,
        layout = wibox.layout.align.vertical
    }

    mediabox:setup {
        --media.cover,
        media.buttons,
        valigh = 'center',
        layout = wibox.container.place,
    }
end)

----------------------------------------------------------------------------------------------------
--                                             WIDGETS                                            --
----------------------------------------------------------------------------------------------------

local qrwidget = {}

qrwidget.music          = require('widgets.music')          -- MUSIC CONTROL
qrwidget.volume         = require('widgets.volume')         -- VOLUME CONTROL
qrwidget.calendar       = require('widgets.calendar')       -- CALENDAR
qrwidget.control_panel  = require('widgets.control_panel')  -- CONTROL PANEL
qrwidget.kbdlayout      = require('widgets.keyboard')       -- KEYBOARD LAYOUT
qrwidget.taglist        = require('widgets.taglist')        -- TAGLIST
qrwidget.tasklist       = require('widgets.tasklist')       -- TASKLIST
qrwidget.current_layout = require('widgets.current_layout') -- CURRENT LAYOUT
qrwidget.systray        = require('widgets.systray')        -- SYSTEM TRAY

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ '1', '2', '3', '4', '5', '6', '7', '8', '9', }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.promptbox = awful.widget.prompt()

    -- Create the top wibar
    s.topwibar   = awful.wibar({
        position = "top",
        stretch  = true,
        screen   = s,
        height   = 40
    })

    -- Add widgets to the top wibar
    s.topwibar:setup {
        direction = "east",
        layout    = wibox.layout.align.horizontal,
        {
            menubutton(s),
            qrwidget.tasklist(s),
            s.promptbox,
            margins = 4,
            widget  = wibox.container.margin,
            layout  = wibox.layout.align.horizontal,
        },
        {
            layout = wibox.layout.fixed.horizontal,
        },
        {
            --qrwidget.music(s),
            qrwidget.volume(s),
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
    --awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
    --          {description = "show main menu", group = "awesome"}),

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
          "Gcr-prompter",
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

--    -- Add titlebars to normal clients and dialogs
--    { rule_any = { type = { "normal", "dialog" }
--      }, properties = { titlebars_enabled = true }
--    },

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

    local top_titlebar = awful.titlebar(c, {
        size           = beautiful.titlebar_size or 28,
        enable_tooltip = false,
        position       = 'top',
    })

    top_titlebar:setup {
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

    --[[
    local bottom_titlebar = awful.titlebar(c, {
        size           = beautiful.titlebar_size or 28,
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
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c)   c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Add shadows to floating windows
local true_useless_gap = beautiful.useless_gap
local orig_client_size = {}
screen.connect_signal("arrange", function (s)
    local layout = s.selected_tag.layout.name
    local is_single_client = #s.clients == 1
    for _, c in pairs(s.clients) do
        if (layout == 'floating' or layout == 'max') then
            beautiful.useless_gap = 0
        else
            beautiful.useless_gap = true_useless_gap
        end
    end

    for _, c in pairs(s.clients) do
        if layout == 'floating' or c.floating and not c.maximized then
            awful.titlebar.show(c)
   			awful.spawn("xprop -id " .. c.window .. " -f _COMPTON_SHADOW 32c -set _COMPTON_SHADOW 1", false)
            c.shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 20)
            end
        else
            awful.titlebar.hide(c)
    		awful.spawn("xprop -id " .. c.window .. " -f _COMPTON_SHADOW 32c -set _COMPTON_SHADOW 0", false)
            c.shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 0)
            end
        end
    end
end)

-- Autostart
awful.spawn.with_shell(os.getenv('HOME') .. '/.screenlayout/layout.sh')
awful.spawn.with_shell(config_dir .. '/scripts/autostart.sh')
--awful.spawn.with_shell('awesome-client '.."'"..'naughty.notify({text = "It works"})'.."'")
--dofile(awful.util.getdir("config") .. "config/autostart.lua")
--awful.spawn("hsetroot -add '#2e3440' -add '#eceff4' -gradient 180")
--awful.spawn('nitrogen --restore')
--awful.spawn('playerctld daemon')
--awful.spawn('lxqt-session -w "awesome"')
--awful.spawn('lxqt-powermanagement')
--awful.spawn('lxqt-policykit-agent')
--awful.spawn.with_shell('picom --config ' .. config_dir .. '/other/picom/picom.conf&')
--naughty.notify { text = autostart }

----------------------------------------------------------------------------------------

--for _, c in pairs(client.get()) do
client.connect_signal('manage', function(c)
    c:connect_signal('property::floating', function()
        c:set_height(c.height - (beautiful.titlebar_size or 28))
    end)
end)

--[[
gears.timer {
    autostart = true,
    callback  = function()
        local widget   = mouse.current_widget
        local x_center = mouse.current_widget_geometry['x'] / 2 + mouse.current_wibox['x']
        --naughty.notify({ text = 'Widget ' .. tostring(widget) .. ' has a geometry of X:' .. tostring(geometry['x']) .. ', Y:' .. tostring(geometry['y']) })
        naughty.notify({ text = 'The center of widget ' .. tostring(widget) .. ' is ' .. tostring(x_center) })
    end
}
--]]