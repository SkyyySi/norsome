naughty.expiration_paused = true

local function notification_bar()
	local notif_wb = awful.wibar {
		bg = '#40404040',
		position = 'left',
		width   = dpi(300),
		--visible  = #naughty.active > 0,
		visible = false,
		stretch = true,
	}

	notif_wb:setup {
		nil,
		{
			base_layout = wibox.widget {
				spacing_widget = wibox.widget {
					orientation = 'horizontal',
					span_ratio  = 0.5,
					widget      = wibox.widget.separator,
				},
				forced_height = 30,
				spacing       = 3,
				layout        = wibox.layout.fixed.vertical,
			},
			widget_template = {
				{
					{
						naughty.widget.icon,
						{
							naughty.widget.title,
							naughty.widget.message,
							{
								layout = wibox.widget {
									-- Adding the wibox.widget allows to share a
									-- single instance for all spacers.
									spacing_widget = wibox.widget {
										orientation = 'vertical',
										span_ratio  = 1,
										widget      = wibox.widget.separator,
									},
									spacing = dpi(3),
									layout  = wibox.layout.flex.vertical
								},
								widget = naughty.list.widgets,
							},
							layout = wibox.layout.align.horizontal
						},
						spacing = dpi(10),
						fill_space = true,
						layout  = wibox.layout.fixed.vertical
					},
					margins = dpi(5),
					widget  = wibox.container.margin
				},
				widget = naughty.list.notifications,
			},
			widget             = wibox.container.background,
			shape              = gears.shape.rounded_rect,
			shape_border_width = dpi(1),
			shape_border_color = beautiful.nord4,
		},
		-- Add a button to dismiss all notifications, because why not.
		{
			{
				{
				--	{
						--text   = 'Dismiss all',
						align  = 'center',
						valign = 'center',
						--widget = wibox.widget.textbox,
						resize = false,
						image  = beautiful.titlebar_close_button_focus,
						widget = wibox.widget.imagebox,
				--	},
				--	layout = wibox.layout.align.vertical
				},
				buttons = gears.table.join(
					awful.button({ }, 1, function()
						naughty.expiration_paused = false
						naughty.destroy_all_notifications()
						naughty.expiration_paused = true
					end)
				),
				forced_width       = 75,
				shape              = gears.shape.rounded_rect,
				shape_border_width = 1,
				shape_border_color = beautiful.bg_highlight,
				widget = wibox.container.background,
			},
			layout = wibox.layout.align.horizontal,
		},
		layout = wibox.layout.align.vertical
	}

	return(notif_wb)
end

return(notification_bar)