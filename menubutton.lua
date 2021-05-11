local terminal    = "termite"
local webbrowser  = "firefox"
local filemanager = "pcmanfm"
local editor      = "code"
local editor_cmd  = editor

-- Create a launcher widget and a main menu
local menu_awesome = {
    { "Show hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "Show manual", terminal .. " -e man awesome" },
    { "Edit config", editor_cmd .. " " .. awesome.conffile },
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

-- Create a menu button
local menubutton = wibox.widget{
    {
        {
            {
                image = '/home/simon/Dokumente/svg/QRLinux-logo-nobg.svg',
                resize = true,
				bg = "#000",
                widget = wibox.widget.imagebox
            },
            top = 4, bottom = 4, left = 8, right = 8,
        	widget = wibox.container.margin
        },
        layout = wibox.layout.align.horizontal
    },
    bg = '#0000',
    widget = wibox.container.background
}

local old_cursor, old_wibox
menubutton:connect_signal("mouse::enter", function(c)
    c:set_bg('#434c5e')
    local wb = mouse.current_wibox
    old_cursor, old_wibox = wb.cursor, wb
    wb.cursor = "hand1" 
end)


menubutton:connect_signal("button::press", function(c, _, _, button) 
    if button == 1 then
        c:set_bg('#4c566a')
    end
end)

menubutton:connect_signal("button::release", function(c, _, _, button) 
    if button == 1 then
        c:set_bg('#434c5e')
        awful.spawn('rofi'..' -show'..' drun')
    
    --[[ elseif button == 2 then
        naughty.notify{text = 'Wheel click'} ]]--
    
    elseif button == 3 then
        awesome_menu:show()
    end
end)

menubutton:connect_signal("mouse::leave", function(c)
    c:set_bg('#0000')
    if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)

return menubutton