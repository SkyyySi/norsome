local rules = {
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
	{ rule_any = { class = {
		'Wrapper-2.0',
		'Ulauncher',
		'Xfce4-panel',
		'krunner',
		'Plank',
	} },
		properties = {
			floating          = true,
			titlebars_enabled = false,
			borderless        = true,
			border_width      = 0,
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

return(rules)