local kbdlayout
function kbdlayout(s)
	s.kbdlayout = wibox.widget {
		{
			{
				{
					awful.widget.keyboardlayout(),
					layout = wibox.layout.align.horizontal,
				},
				margins = dpi(4),
				widget  = wibox.container.margin,
			},
			bg                 = beautiful.nord1,
			shape              = gears.shape.rounded_bar,
			shape_border_width = dpi(1),
			shape_border_color = beautiful.nord4,
			widget             = wibox.container.background,
		},
		margins = dpi(4),
		widget  = wibox.container.margin,
	}
	return(s.kbdlayout)
end

return(kbdlayout)