xdg_menu = require('archmenu')

-- Generate an xdg app menu
awful.spawn.with_shell('xdg_menu --format awesome --root-menu /etc/xdg/menus/arch-applications.menu > ' .. config_dir .. '/archmenu.lua')

-- Create a launcher widget and a main menu.
-- Entries related to awesome itself
local menu_awesome = {
	{ 'Show hotkeys', function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
	{ 'Show manual', terminal .. ' -e man awesome' },
--    { 'Edit config', editor_cmd .. ' ' .. awesome.conffile },
	{ 'Edit config', editor_cmd .. ' ' .. config_dir },
	{ 'Restart awesome', awesome.restart },
	{ 'Quit awesome', function() awesome.quit() end },
}

-- Entries related to power management
local menu_power = {
	{ 'Lock session', 'loginctl lock-session' },
	{ 'Shutdown',     'sudo poweroff'         },
	{ 'Reboot',       'sudo reboot'           },
	{ 'Suspend',      'systemctl suspend'     },
	{ 'Hibernate',    'systemctl hibernate'   },
}

-- Assemble all menus into one
local awesome_menu = awful.menu {
	items = {
		{ 'Awesome',      menu_awesome, beautiful.awesome_icon  },
		{ 'Power',        menu_power,   beautiful.icon.power    },
		{ 'Applications', xdgmenu,      beautiful.icon.app      },
		{ 'Terminal',     terminal,     beautiful.icon.terminal },
		{ 'File manager', filemanager,  beautiful.icon.folder   },
		{ 'Web browser',  webbrowser,   beautiful.icon.web      },
	},
	shape = gears.shape.rounded_rect
}

return(awesome_menu)