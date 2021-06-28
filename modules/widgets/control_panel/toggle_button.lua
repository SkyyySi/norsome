local rounded_rectangle = require('rounded_rectangle')
local buttonify         = require('buttonify')

local function button(arg)
	local icon                = arg.icon                or beautiful.awesome_icon
	local title               = arg.title               or 'A button'
	local deactivate          = arg.deactivate          or 'never' -- 'never' = don't deactivate; 'signal' = only decativate when a signal was received to do so (true means on, false means off); 'always' = re-color no matter if something changed (and emmit signal if set)
	local deactivation_signal = arg.deactivation_signal or nil
	local lclick              = arg.lclick              or function() return(nil) end
	local mclick              = arg.mclick              or function() return(nil) end
	local rclick              = arg.rclick              or function() return(nil) end
	--[[ local lclick              = arg.lclick              or function()
		naughty.notification {
			urgency = 'normal',
			title   = 'Message from "'..title..'":',
			message = 'You should define a left click function for me!'
		}
	end ]]

	-- The icon widget itself is defined seperately so it can be easily altered at will.
	local icon_widget = wibox.widget {
		image  = icon,
		widget = wibox.widget.imagebox,
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
			bg     = beautiful.control_panel_toggle_button_normal or beautiful.nord10 or '#5E81AC',
			shape  = gears.shape.squircle,
			widget = wibox.container.background,
		},
		margins = dpi(4),
		widget  = wibox.container.margin,
	}

	-- This is the widget that contains the button and that will get shown in the control pannel
	local widget = wibox.widget {
		{
			{
				{
					nil,
					{
						{
							{
								icon_widget_container,
								layout   = wibox.layout.fixed.horizontal,
							},
							strategy = 'max',
							width    = dpi(64),
							widget   = wibox.container.constraint,
						},
						valign = 'center',
						halign = 'center',
						layout = wibox.container.place,
					},
					nil,
					layout = wibox.layout.align.horizontal,
				},
				{
					nil,
					{
						text   = title,
						align  = 'center',
						widget = wibox.widget.textbox,
					},
					nil,
					layout = wibox.layout.align.horizontal,
				},
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

	widget.active = true

	-- Mouse hovor and click effects
	if (widget.active == false) then
		icon_widget_container.widget:set_bg(beautiful.control_panel_toggle_button_normal_inactive or beautiful.nord0 or '#2E3440')
	end

	local function set_button_color (type, deac)
		local d = 'active'
		local str
		if (deac == false) then d = 'inactive' end
		local normal_active    = beautiful.control_panel_toggle_button_normal_active    or beautiful.nord10 or '#5E81AC'
		local enter_active     = beautiful.control_panel_toggle_button_enter_active     or beautiful.nord9  or '#81A1C1'
		local press_active     = beautiful.control_panel_toggle_button_press_active     or beautiful.nord8  or '#88C0D0'
		local release_active   = beautiful.control_panel_toggle_button_release_active   or beautiful.nord9  or '#81A1C1'
		local normal_inactive  = beautiful.control_panel_toggle_button_normal_inactive  or beautiful.nord0  or '#2E3440'
		local enter_inactive   = beautiful.control_panel_toggle_button_enter_inactive   or beautiful.nord1  or '#3B4252'
		local press_inactive   = beautiful.control_panel_toggle_button_press_inactive   or beautiful.nord2  or '#434C5E'
		local release_inactive = beautiful.control_panel_toggle_button_release_inactive or beautiful.nord1  or '#3B4252'

		-- load() would be much better here, but I cannot get it to work, so it's hardcoded :/
		str = (type..'_'..d)
		    if (str == 'normal_active')    then return(normal_active)
		elseif (str == 'enter_active')     then return(enter_active)
		elseif (str == 'press_active')     then return(press_active)
		elseif (str == 'release_active')   then return(release_active)
		elseif (str == 'normal_inactive')  then return(normal_inactive)
		elseif (str == 'enter_inactive')   then return(enter_inactive)
		elseif (str == 'press_inactive')   then return(press_inactive)
		elseif (str == 'release_inactive') then return(release_inactive)
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

	if ((deactivation_signal) and (deactivate == 'signal' or deactivate == 'always')) then
		awesome.connect_signal(deactivation_signal, function()
			widget.active = (not widget.active)
		end)
	end

	return(widget)
end

return(button)
