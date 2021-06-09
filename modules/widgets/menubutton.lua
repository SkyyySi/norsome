local menubutton
function menubutton(s)
	local s = s or awful.screen.focused()

	if not awesome_menu then
		s.menu_awesome = menu_awesome or {}
		s.menu_power   = menu_power   or {}
		s.awesome_menu = awesome_menu or {}
	else
		-- Create a launcher widget and a main menu
		s.menu_awesome = {
			{ "Show hotkeys",    function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
			{ "Show manual",     terminal .. " -e man awesome"                                       },
			{ "Edit config",     editor_cmd or 'code'                                                },
			{ "Restart awesome", awesome.restart                                                     },
			{ "Quit awesome",    function() awesome.quit() end                                       },
		}

		s.menu_power = {
			{ "Lock session", "loginctl  lock-session" },
			{ "Shutdown",     "systemctl shutdown"     },
			{ "Reboot",       "systemctl reboot"       },
			{ "Suspend",      "systemctl suspend"      },
			{ "Hibernate",    "systemctl hibernate"    },
		}

		s.awesome_menu = awful.menu({items = {
			{ "Awesome",      s.menu_awesome, beautiful.awesome_icon },
			{ "Power",        s.menu_power                           },
			{ "Terminal",     terminal or 'xterm'                    },
			{ "Web browser",  webbrowser or 'firefox'                },
			{ "File manager", filemanager or 'pcmanfm-qt'            },
		}})
	end

    -- Create a menu button
    s.menubutton = wibox.widget{
        {
            {
                {
                    image = '/home/simon/Dokumente/svg/QRLinux-logo-nobg.svg',
                    resize = true,
                    bg = "#000",
                    widget = wibox.widget.imagebox
                },
                top = dpi(4), bottom = dpi(4), left = dpi(8), right = dpi(8),
                widget = wibox.container.margin
            },
            layout = wibox.layout.align.horizontal
        },
        bg = '#0000',
        widget = wibox.container.background
    }

    local old_cursor, old_wibox
    s.menubutton:connect_signal("mouse::enter", function(c)
        c:set_bg('#434c5e')
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand1"
    end)


    s.menubutton:connect_signal("button::press", function(c, _, _, button)
        if (button == 1 or 2 or 3) then
            c:set_bg('#4c566a')
        end
    end)

    s.menubutton:connect_signal("button::release", function(c, _, _, button)
        if button == 1 then
            c:set_bg('#434c5e')
            awful.spawn('rofi -show drun -config ' .. awful.util.getdir('config') .. '/other/rofi/config.rasi')
        elseif button == 2 then
            c:set_bg('#434c5e')
            awful.spawn('lxqt-config')
        elseif button == 3 then
            c:set_bg('#434c5e')
            s.awesome_menu:toggle()
        end
    end)

    s.menubutton:connect_signal("mouse::leave", function(c)
        c:set_bg('#0000')
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    return(s.menubutton)
end

return(menubutton)
