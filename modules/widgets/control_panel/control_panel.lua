local rounded_rectangle = require('rounded_rectangle')
local buttonify         = require('buttonify')

local control_panel_widget
function control_panel_widget(s)
    local s = s or awful.screen.focused()
	s.control_panel        = {}
	s.control_panel.widget = {}
	s.control_panel.width  = dpi(400)

	s.control_panel.widget.volume_slider = require('widgets.control_panel.widgets.volume')

	s.control_panel.control_panel = awful.wibar {
		bg       = beautiful.control_panel_bg,
		position = 'right',
		stretch  = true,
		visible  = false,
		ontop    = true,
		screen   = s,
		width    = s.control_panel.width,
		layout   = wibox.layout.flex.vertical,
	}

	s.control_panel.control_panel:setup {
		direction = 'east',
		layout    = wibox.layout.flex.vertical,
		{
			{
				{
					nil,
					layout = wibox.layout.fixed.horizontal,
				},
				{
					nil,
					layout = wibox.layout.fixed.horizontal,
				},
				{
					s.control_panel.widget.volume_slider(s, s.control_panel.width),
					layout = wibox.layout.fixed.horizontal,
				},
				bg     = beautiful.nord2,
				widget = wibox.container.background,
				layout = wibox.layout.fixed.vertical,
			},
			margins = 10,
			widget  = wibox.container.margin,
		},
	}

	s.control_panel.control_panel_button = wibox.widget{
		{{{
					font   = 'Source Code Pro Black 22',
					text   = '◀',
					widget = wibox.widget.textbox,
				},
				top    = dpi(4),
				bottom = dpi(4),
				left   = dpi(8),
				right  = dpi(8),
				widget = wibox.container.margin,
			},
			bg                 = beautiful.button_normal,
			shape_border_width = dpi(1),
			shape_border_color = '#d8dee9',
			shape              = gears.shape.rounded_bar,
			widget             = wibox.container.background,
		},
		margins = dpi(4),
		widget  = wibox.container.margin,
	}

	function s.control_panel.set_bar_visibility(t)
		if t then
			s.control_panel.control_panel.visible                          = true
			s.control_panel.control_panel_button.widget.widget.widget.text = '▶'
		else
			s.control_panel.control_panel.visible                          = false
			s.control_panel.control_panel_button.widget.widget.widget.text = '◀'
		end
	end

	s.control_panel.set_bar_visibility(false)

	buttonify({widget = s.control_panel.control_panel_button.widget})
	s.control_panel.control_panel_button.widget:connect_signal('button::release', function(c)
		s.control_panel.set_bar_visibility(not s.control_panel.control_panel.visible)
	end)

	return(s.control_panel.control_panel_button)
end

return(control_panel_widget)