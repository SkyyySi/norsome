naughty.expiration_paused = true

local dismiss_all_button = wibox.widget {
	{
		text   = 'Dismiss all',
		align  = 'center',
		valign = 'center',
		widget = wibox.widget.textbox,
	},
	buttons = gears.table.join(
		awful.button({ }, 1, function()
			naughty.expiration_paused = false
			naughty.destroy_all_notifications()
			naughty.expiration_paused = true
		end)
	),
	forced_width       = dpi(75),
	bg                 = beautiful.button_normal,
	shape              = gears.shape.rounded_bar,
	shape_border_width = dpi(1),
	shape_border_color = beautiful.bg_highlight,
	widget             = wibox.container.background,
}

buttonify {
	widget         = dismiss_all_button,
	button_enter   = beautiful.nord12,
	button_press   = beautiful.nord11,
	button_release = beautiful.nord12,
}

local notification_container = wibox.widget {
	{
		-- Add a button to dismiss all notifications, because why not.
		dismiss_all_button,
		{
			base_layout = wibox.widget {
				--spacing_widget = wibox.widget {
				--	orientation = 'horizontal',
				--	span_ratio  = 0.5,
				--	widget      = wibox.widget.separator,
				--},
				spacing = dpi(3),
				layout  = wibox.layout.fixed.vertical,
			},
			widget_template = {
				naughty.widget.icon,
				{
					{
						{
							{
								naughty.widget.title,
								naughty.widget.message,
								{
									layout = wibox.widget {
										-- Adding the wibox.widget allows to share a
										-- single instance for all spacers.
										spacing_widget = wibox.widget {
											orientation = 'vertical',
											span_ratio  = 0.9,
											widget      = wibox.widget.separator,
										},
										layout  = wibox.layout.flex.horizontal,
									},
									widget = naughty.list.widgets,
								},
								layout = wibox.layout.align.horizontal,
							},
							margins = dpi(4),
							widget  = wibox.container.margin,
						},
						bg                 = beautiful.notification_bg                 or '#4C566A',
						shape              = beautiful.notification_shape              or gears.shape.rounded_rect,
						shape_border_width = beautiful.notification_shape_border_width or dpi(1),
						shape_border_color = beautiful.notification_shape_border_color or '#D8DEE9',
						widget             = wibox.container.background,
					},
					top    = dpi(4),
					bottom = dpi(4),
					widget = wibox.container.margin,
				},
				spacing    = 0,
				fill_space = false,
				layout     = wibox.layout.align.horizontal,
			},
			widget = naughty.list.notifications,
		},
		layout = wibox.layout.align.vertical,
	},
	margins = dpi(16),
	widget  = wibox.container.margin,
}

return(notification_container)