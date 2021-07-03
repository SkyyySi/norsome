local rounded_rectangle = require('rounded_rectangle')
--[[
Experimentation with gears.color, please ignore.
local function gen_color(x0, y0, x1, y1, stop)
	x0 = x0 or 0
	y0 = y0 or 0
	x1 = x1 or 100
	y1 = y1 or 100
	stop = stop or { { 0, '#ff0000' }, { 0.5, '#00ff00' }, { 1, '#0000ff' } }
	return( gears.color {
		type  = 'linear',
		from  = { x0, y0 },
		to    = { x1, y1 },
		stops = stop
	} )
end

local test = wibox {
	width   = dpi(200),
	height  = dpi(50),
	bg      = gears.color {
		type  = 'linear',
		from  = { 0, 0 },
		to    = { dpi(200), 0 },
		stops = { { 0, beautiful.nord11 }, { 0.5, beautiful.nord12 }, { 1, beautiful.nord13 } }
	},
	visible = true,
	ontop   = true,
}
--]]

local volume_widget
function volume_widget()
	local main = {}

	main.volume_slider_text   = wibox.widget {
		font   = 'Source Code Pro Black 16',
		text   = ' 🔊 ',
		widget = wibox.widget.textbox,
	}

	main.volume_slider_widget = wibox.widget {
		bar_shape           = beautiful.qrwidget_volume_slider_bar_shape           or gears.shape.rounded_bar,
		bar_height          = beautiful.qrwidget_volume_slider_bar_height          or dpi(4),
		bar_color           = beautiful.qrwidget_volume_slider_bar_color           or '#8FBCBB',
		handle_color        = beautiful.qrwidget_volume_slider_handle_color_normal or '#D8DEE9',
		handle_shape        = beautiful.qrwidget_volume_slider_handle_shape        or gears.shape.circle,
		handle_border_color = beautiful.qrwidget_volume_slider_handle_border_color or '#4C566A',
		handle_border_width = beautiful.qrwidget_volume_slider_handle_border_width or dpi(2),
		value               = 50,
		minimum             = 0,
		maximum             = 100,
		widget              = wibox.widget.slider,
	}
	awful.spawn.easy_async_with_shell('pamixer --get-volume', function(v)
		main.volume_slider_widget:set_value(tonumber(v))
	end)

	awesome.connect_signal('qrlinux::media::get_volume', function(volume)
		local text = volume
		local v = tostring(text)
		    if #v == 1 then v = (v .. '  ')
		elseif #v == 2 then v = (v .. ' ' )
		end

			if volume == 0 then text = ' 🔇 ' .. v .. ' '
		elseif volume < 25 then text = ' 🔈 ' .. v .. ' '
		elseif volume < 75 then text = ' 🔉 ' .. v .. ' '
		else                    text = ' 🔊 ' .. v .. ' '
		end
		main.volume_slider_text:set_text(tostring(text))
	end)

	main.volume_slider = wibox.widget {
		main.volume_slider_text,
		main.volume_slider_widget,
		layout = wibox.layout.fixed.horizontal,
	}

	function main.update_volume(value)
		local v = tonumber(value)
		awesome.emit_signal('qrlinux::media::set_volume', v)
		main.volume_slider_widget.value = v
	end

	awesome.connect_signal('qrlinux::media::get_volume', function(v)
		v = tonumber(v)
		if mouse.current_widget ~= main.volume_slider_widget and not mouse.is_left_mouse_button_pressed then
			main.update_volume(v)
		end
	end)

	main.volume_slider_widget:connect_signal('property::value', function(c)
		local v = c.value
		main.update_volume(v)
	end)

	main.main_widget = wibox.widget {
		{
			{
				{
					main.volume_slider,
					layout = wibox.layout.align.horizontal,
				},
				left   = dpi(4),
				right  = dpi(16),
				widget = wibox.container.margin,
			},
			layout = wibox.layout.fixed.horizontal,
		},
		strategy = 'max',
		height   = dpi(60),
		widget   = wibox.container.constraint
	}

	local old_cursor, old_wibox
	main.volume_slider_widget:connect_signal('mouse::enter', function(c)
		c:set_handle_color(beautiful.qrwidget_volume_slider_handle_color_hover or '#ECEFF4')
		local wb = mouse.current_wibox
		old_cursor, old_wibox = wb.cursor, wb
		wb.cursor = 'hand1'
	end)
	main.volume_slider_widget:connect_signal('mouse::leave', function(c)
		c:set_handle_color(beautiful.qrwidget_volume_slider_handle_color_normal or '#D8DEE9')
		if old_wibox then
			old_wibox.cursor = old_cursor
			old_wibox = nil
		end
	end)

	return(main.main_widget)
end

return(volume_widget)