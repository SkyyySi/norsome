local keyboard
function keyboard()
	local widget = wibox.widget {
		{
			{
				{
					awful.widget.keyboardlayout(),
					layout = wibox.layout.align.horizontal,
				},
				margins = 4,
				widget  = wibox.container.margin,
			},
			bg                 = beautiful.nord1,
			shape              = gears.shape.rounded_bar,
			shape_border_width = 1,
			shape_border_color = beautiful.nord4,
			widget             = wibox.container.background,
		},
		margins = 4,
		widget  = wibox.container.margin,
	}
	return(widget)
end

return(keyboard)