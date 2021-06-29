-- Tip: pass `screen.primary` as the argument, that way it'll always
-- be placed on... well, your primary screen :)
--- SYSTEM TRAY ---
systray_placed  = false
local systray
function systray()
	local systray_widget = wibox.widget {
		test = { 1,  2, 'AC'},
		screen         = 'primary',
		reverse        = false,
		set_horizontal = true,
		set_base_size  = dpi(22),
		forced_height  = dpi(20),
		widget         = wibox.widget.systray,
	}

	local systray_container = wibox.widget{
		{
			{
				{
					systray_widget,
					top    = dpi(4),
					left   = dpi(20),
					right  = dpi(20),
					widget = wibox.container.margin,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			bg                 = beautiful.bg_systray,
			shape_border_color = '#d8dee9',
			shape_border_width = dpi(1),
			shape              = gears.shape.rounded_bar,
			widget             = wibox.container.background,
		},
		margins = dpi(4),
		widget  = wibox.container.margin,
	}

	-- This code is not working, it's here as a reminder that I should implement dynamic hiding.
	--[[ systray_widget:connect_signal('property::children', function(f)
		local t = 'all_children:\n'
		for k, v in pairs(f) do
			t = t .. ('key: ' .. tostring(k).. ', value: '  .. v .. '\n')
		end
		naughty.notify { text = tostring(t) }
	end) --]]

	-- You can't have multiple systrays
	if not systray_placed then
		systray_placed = true
		return(systray_container)
	else
		return(nil)
	end
end

return(systray)