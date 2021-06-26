
-- Create an imagebox widget which will contain an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local buttonify = require('buttonify')
local current_wibox
function current_wibox(s)
	local layoutbox = wibox.widget {
		{
			{
				{
					awful.widget.layoutbox(s),
					layout = wibox.layout.align.horizontal,
				},
				top    = dpi(4),
				bottom = dpi(4),
				left   = dpi(10),
				right  = dpi(10),
				widget = wibox.container.margin,
			},
			bg                 = beautiful.button_normal       or '#3B4252',
			shape              = beautiful.button_border_shape or gears.shape.rounded_bar,
			shape_border_width = beautiful.button_border_width or dpi(1),
			shape_border_color = beautiful.button_border_color or '#D8DEE9',
			widget             = wibox.container.background,
		},
		margins = dpi(4),
		widget  = wibox.container.margin,
	}
	buttonify({ widget = layoutbox.widget })

	layoutbox:buttons(gears.table.join(
		awful.button({ }, 1, function () awful.layout.inc( 1) end),
		awful.button({ }, 3, function () awful.layout.inc(-1) end),
		awful.button({ }, 4, function () awful.layout.inc( 1) end),
		awful.button({ }, 5, function () awful.layout.inc(-1) end)
	))

	return(layoutbox)
end

return(current_wibox)