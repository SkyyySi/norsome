local rounded_rectangle = require('rounded_rectangle')
local infobubble        = require('infobubble')
local buttonify         = require('buttonify')

local wallpaper_select
function wallpaper_select(s, arg)
	if not s   then local s   = {} end
	if not arg then local arg = {} end
	s               = s or screen.primary
	s.size          = arg.wp_size or 100
	s.spacing       = arg.spacing or dpi(5)
	s.cols          = arg.cols or 4 -- horizontal
	s.rows          = arg.rows or 5 -- versical
	s.min_cols_size = arg.min_cols_size or nil
	s.min_rows_size = arg.min_rows_size or nil

	s.wp_widget_button_text = wibox.widget {
		text   = 'Change wallpaper',
		widget = wibox.widget.textbox,
	}

	s.wp_widget_button = wibox.widget {
		{
			{
				{
					s.wp_widget_button_text,
					layout = wibox.layout.align.horizontal,
				},
				margins = dpi(8),
				widget  = wibox.container.margin,
			},
			bg                 = beautiful.button_normal or '#3B4252',
			shape              = beautiful.button_border_shape or gears.shape.rounded_bar,
			shape_border_width = beautiful.button_border_width or dpi(1),
			shape_border_color = beautiful.button_border_color or '#D8DEE9',
			widget             = wibox.container.background,
		},
		margins = dpi(4),
		widget  = wibox.container.margin,
	}
	buttonify({widget = s.wp_widget_button.widget})

	s.wp_widget = wibox {
		screen  = s,
		type    = 'utility',
		visible = false,
		ontop   = true,
		bg      = '#00000080',
		width   = (s.size * s.cols),
		height  = (s.size * s.rows),
	}

	s.wp_widget_button:connect_signal('button::press', function(_,_,_,b)
		if b == 1 then
			s.wp_widget.visible = not s.wp_widget.visible
			center = (mouse.current_widget_geometry.x - ((s.wp_widget.width / 2) or 0))
			awful.placement.top_left(s.wp_widget, { margins = {top = dpi(48), left = center }, parent = s })
		end
	end)

	return(s.wp_widget_button)
end

return(wallpaper_select)