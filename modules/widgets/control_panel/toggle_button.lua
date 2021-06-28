local rounded_rectangle = require('rounded_rectangle')
--local buttonify = require('buttonify')

local function button(arg)
	local icon_active                = arg.icon_active or arg.icon   or beautiful.awesome_icon
	local icon_inactive              = arg.icon_inactive             or icon_active
	local icon_bg_normal_active      = arg.icon_bg_normal_active     or beautiful.control_panel_toggle_button_icon_bg_normal_active    or '#5E81AC'
	local icon_bg_enter_active       = arg.icon_bg_enter_active      or beautiful.control_panel_toggle_button_icon_bg_enter_active     or '#81A1C1'
	local icon_bg_press_active       = arg.icon_bg_press_active      or beautiful.control_panel_toggle_button_icon_bg_press_active     or '#88C0D0'
	local icon_bg_release_active     = arg.icon_bg_release_active    or beautiful.control_panel_toggle_button_icon_bg_release_active   or '#81A1C1'
	local icon_bg_normal_inactive    = arg.icon_bg_normal_inactive   or beautiful.control_panel_toggle_button_icon_bg_normal_inactive  or '#2E3440'
	local icon_bg_enter_inactive     = arg.icon_bg_enter_inactive    or beautiful.control_panel_toggle_button_icon_bg_enter_inactive   or '#3B4252'
	local icon_bg_press_inactive     = arg.icon_bg_press_inactive    or beautiful.control_panel_toggle_button_icon_bg_press_inactive   or '#434C5E'
	local icon_bg_release_inactive   = arg.icon_bg_release_inactive  or beautiful.control_panel_toggle_button_icon_bg_release_inactive or '#3B4252'
	local icon_bg_shape              = arg.icon_bg_shape             or beautiful.control_panel_toggle_button_icon_bg_shape            or gears.shape.circle
	local icon_bg_shape_border_color = arg.icon_shape_border_color   or beautiful.control_panel_toggle_button_icon_shape_border_color  or '#FFFFFF'
	local icon_bg_shape_border_width = arg.icon_shape_border_width   or beautiful.control_panel_toggle_button_icon_shape_border_width  or 0
	local title_active               = arg.title_active or arg.title or 'A button'
	local title_inactive             = arg.title_inactive            or title_active
	local false_tmp = false -- This is a workaround since using false directly wouldn't work.
	local active                     = false_tmp                     or arg.active
	local control_signal             = arg.control_signal            or nil -- This signal will enable (or disable the button)
	local deactivate                 = arg.deactivate                or 'never' -- 'never' = don't deactivate; 'signal' = only decativate when a signal was received to do so (true means on, false means off); 'always' = re-color no matter if something changed (and emmit signal if set)
	local deactivation_signal        = arg.deactivation_signal       or nil
	local lclick                     = arg.lclick                    or function() return(nil) end
	local mclick                     = arg.mclick                    or function() return(nil) end
	local rclick                     = arg.rclick                    or function() return(nil) end
	--[[ local lclick              = arg.lclick              or function()
		naughty.notification {
			urgency = 'normal',
			title   = 'Message from "'..title..'":',
			message = 'You should define a left click function for me!'
		}
	end ]]

	-- The icon widget itself is defined seperately so it can be easily altered at will.
	local icon
	if active then icon = icon_active else icon = icon_inactive end

	local icon_widget = wibox.widget {
		image  = icon,
		widget = wibox.widget.imagebox,
	}

	-- Same goes for the title widget.
	local title
	if active then title = title_active else title = title_inactive end

	local title_widget = wibox.widget {
		text   = title,
		align  = 'center',
		widget = wibox.widget.textbox,
	}

	-- This widget contains the icon to add a background color and to align it properly.
	local icon_widget_container = wibox.widget {
		{
			{
				{
					widget = icon_widget,
				},
				margins = dpi(4),
				widget  = wibox.container.margin,
				layout  = wibox.layout.align.vertical,
			},
			bg                 = icon_bg_normal_active,
			shape              = icon_bg_shape,
			shape_border_color = icon_bg_shape_border_color,
			shape_border_width = icon_bg_shape_border_width,
			widget             = wibox.container.background,
		},
		margins = dpi(4),
		widget  = wibox.container.margin,
	}

	-- This is the widget that contains the button and that will get shown in the control pannel
	local widget = wibox.widget {
		{
			{
				{
					{
						{
							widget = icon_widget_container,
						},
						strategy = 'max',
						width    = dpi(64),
						widget   = wibox.container.constraint,
					},
					valign = 'center',
					halign = 'center',
					layout = wibox.container.place,
				},
				title_widget,
				layout = wibox.layout.align.vertical,
			},
			strategy     = 'max',
			forced_width = dpi(32),
			widget       = wibox.container.constraint,
		},
		bg                 = beautiful.nord3,
		shape              = rounded_rectangle(dpi(8)),
		shape_border_width = dpi(1),
		shape_border_color = beautiful.nord4,
		widget             = wibox.widget.background,
	}

	widget.active = active

	-- Mouse hovor and click effects
	if (widget.active == false) then
		icon_widget_container.widget:set_bg(beautiful.control_panel_toggle_button_normal_inactive or beautiful.nord0 or '#2E3440')
	end

	local function set_button_color (type, deac)
		local d = 'active'
		local str
		if (deac == false) then d = 'inactive' end
		-- load() would be much better here, but I cannot get it to work, so it's hardcoded :/
		str = (type..'_'..d)
		    if (str == 'normal_active'   ) then return(icon_bg_normal_active   )
		elseif (str == 'enter_active'    ) then return(icon_bg_enter_active    )
		elseif (str == 'press_active'    ) then return(icon_bg_press_active    )
		elseif (str == 'release_active'  ) then return(icon_bg_release_active  )
		elseif (str == 'normal_inactive' ) then return(icon_bg_normal_inactive )
		elseif (str == 'enter_inactive'  ) then return(icon_bg_enter_inactive  )
		elseif (str == 'press_inactive'  ) then return(icon_bg_press_inactive  )
		elseif (str == 'release_inactive') then return(icon_bg_release_inactive)
		end
	end

	local old_cursor, old_wibox
	icon_widget_container.widget:connect_signal('mouse::enter', function(c)
		c:set_bg(set_button_color('enter', widget.active))
		local wb = mouse.current_wibox
		old_cursor, old_wibox = wb.cursor, wb
		wb.cursor = 'hand1'
	end)
	icon_widget_container.widget:connect_signal('mouse::leave', function(c)
		c:set_bg(set_button_color('normal', widget.active))
		if old_wibox then
			old_wibox.cursor = old_cursor
			old_wibox = nil
		end
	end)
	icon_widget_container.widget:connect_signal('button::press', function(c)
		c:set_bg(set_button_color('press', (widget.active)))
		if (deactivate == 'always') then
			widget.active = (not widget.active)
		end
	end)

	-- Do something when the button is clicked
	icon_widget_container.widget:connect_signal('button::release', function(c,_,_,b)
		-- Without the .widget above, the insibile margin would be
		-- concidered to be a part of the toggle button.
		c:set_bg(set_button_color('release', (widget.active)))

		if (b == 1) then -- Left click
			lclick()
		elseif (b == 2) then -- Middle click
			mclick()
		elseif (b == 3) then -- Right click
			rclick()
		end
	end)

	if (deactivation_signal and (deactivate == 'signal' or deactivate == 'always') and not control_signal) then
		awesome.connect_signal(deactivation_signal, function()
			widget.active = (not widget.active)
		end)
	end

	if (control_signal and not deactivation_signal) then
		awesome.connect_signal(control_signal, function(status)
			widget.active = status
			icon_widget_container.widget:set_bg(set_button_color('normal', widget.active))
		end)
	end

	return(widget)
end

return(button)
