local volume_slider
function volume_slider(s, w)
	s.control_panel.volume_slider = {}

	s.control_panel.volume_slider.volume_slider_text   = wibox.widget {
		font   = 'Source Code Pro Black 16',
		text   = ' 🔊 ',
		widget = wibox.widget.textbox,
	}

	s.control_panel.volume_slider.volume_slider_widget = wibox.widget {
		bar_shape           = gears.shape.rounded_bar,
		bar_height          = dpi(4),
		bar_color           = beautiful.nord8,
		handle_color        = beautiful.nord4,
		handle_shape        = gears.shape.circle,
		handle_border_color = beautiful.nord3,
		handle_border_width = dpi(2),
		value               = dpi(50),
		minimum             = dpi(0),
		maximum             = dpi(100),
		widget              = wibox.widget.slider,
	}

	awful.spawn.easy_async_with_shell('pamixer --get-volume', function(v)
		s.control_panel.volume_slider.volume_slider_widget:set_value(tonumber(v))
	end)

	awesome.connect_signal('qrlinux::media::get_volume', function(volume)
		local text = volume
			if volume == 0 then text = ' 🔇 ' .. tostring(volume) .. ' '
		elseif volume < 25 then text = ' 🔈 ' .. tostring(volume) .. ' '
		elseif volume < 75 then text = ' 🔉 ' .. tostring(volume) .. ' '
		else                    text = ' 🔊 ' .. tostring(volume) .. ' '
		end
		s.control_panel.volume_slider.volume_slider_text:set_text(text)
	end)

	s.control_panel.volume_slider.volume_slider = wibox.widget {
		s.control_panel.volume_slider.volume_slider_text,
		s.control_panel.volume_slider.volume_slider_widget,
		layout = wibox.layout.fixed.horizontal,
	}

	function s.control_panel.volume_slider.update_volume(value)
		local v = tonumber(value)
		awesome.emit_signal('qrlinux::media::set_volume', v)
		s.control_panel.volume_slider.volume_slider_widget.value = v
	end

	awesome.connect_signal('qrlinux::media::get_volume', function(v)
		v = tonumber(v)
		if mouse.current_widget ~= s.control_panel.volume_slider.volume_slider_widget and not mouse.is_left_mouse_button_pressed then
			s.control_panel.volume_slider.update_volume(v)
		end
	end)

	s.control_panel.volume_slider.volume_slider_widget:connect_signal('property::value', function(c)
		local v = c.value
		s.control_panel.volume_slider.update_volume(v)
	end)

	s.control_panel.volume_slider.main_widget = wibox.widget {
		{
			{
				{
					s.control_panel.volume_slider.volume_slider,
					layout = wibox.layout.align.horizontal,
				},
				left   = dpi(15),
				right  = dpi(15),
				widget = wibox.container.margin,
			},
			bg                 = beautiful.nord0,
			shape              = gears.shape.rounded_bar,
			shape_border_color = beautiful.nord4,
			shape_border_width = dpi(2),
			widget             = wibox.container.background,
		},
		strategy = 'exact',
		--width    = w - dpi(20),
		height   = dpi(60),
		widget   = wibox.container.constraint
	}

	local old_cursor, old_wibox
	s.control_panel.volume_slider.volume_slider_widget:connect_signal('mouse::enter', function(c)
		c:set_handle_color(beautiful.nord7)
		local wb = mouse.current_wibox
		old_cursor, old_wibox = wb.cursor, wb
		wb.cursor = 'hand1'
	end)
	s.control_panel.volume_slider.volume_slider_widget:connect_signal('mouse::leave', function(c)
		c:set_handle_color(beautiful.nord4)
		if old_wibox then
			old_wibox.cursor = old_cursor
			old_wibox = nil
		end
	end)

	s.control_panel.volume_slider.volume_slider_widget:connect_signal('button::press',   function(c) c:set_handle_color(beautiful.nord8) end)
	s.control_panel.volume_slider.volume_slider_widget:connect_signal('button::release', function(c) c:set_handle_color(beautiful.nord7) end)

	return(s.control_panel.volume_slider.main_widget)
end

return(volume_slider)