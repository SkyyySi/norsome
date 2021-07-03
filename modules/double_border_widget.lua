local function double_border_widget(arg)
	local prop = {}
	prop.widget             = arg.widget
	prop.margins            = arg.margins     or beautiful.qrwidget_margin             or dpi(0)
	prop.bg                 = arg.bg          or beautiful.qrwidget_bg                 or '#2E3440'
	prop.shape              = arg.shape       or beautiful.qrwidget_shape              or rounded_rectangle(dpi(20))
	prop.shape_border_width = arg.shape_width or beautiful.qrwidget_shape_border_width or dpi(1)
	prop.shape_border_color = arg.shape_color or beautiful.qrwidget_shape_border_color or '#D8DEE9'

	local widget = wibox.widget {
		{
			{
				{
					{
						widget = prop.widget
					},
					margins = prop.margins,
					widget  = wibox.container.margin,
				},
				bg                 = prop.bg,
				shape              = prop.shape,
				shape_border_width = prop.shape_border_width,
				shape_border_color = prop.shape_border_color,
				widget             = wibox.container.background,
			},
			margins = dpi(1),
			widget  = wibox.container.margin,
		},
		bg                 = prop.shape_border_color,
		shape              = prop.shape,
		shape_border_width = prop.shape_border_width,
		shape_border_color = prop.bg,
		widget             = wibox.container.background,
	}

	return(widget)
end

return(double_border_widget)