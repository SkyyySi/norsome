local rounded_rectangle = require('rounded_rectangle')
local buttonify         = require('buttonify')
local toggle_button     = require('widgets.control_panel.toggle_button')

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
	}
	--[[if (s == screen.primary()) then
		s.control_panel.control_panel.visible = true
	end --]]

	local toggle_button_container_textbox = wibox.widget {
		text = 'Hello, world!',
		widget = wibox.widget.textbox,
	}
	local function toggle_button_container_nightmode()
		local w = wibox.widget {
			{
				{
					{
						image  = beautiful.icon.night_mode,
						widget = wibox.widget.imagebox,
					},
					margins = dpi(4),
					widget  = wibox.container.margin,
					layout  = wibox.layout.align.vertical,
				},
				bg     = beautiful.nord10 or '#5E81AC',
				shape  = gears.shape.squircle,
				widget = wibox.container.background,
			},
			margins = dpi(4),
			widget  = wibox.container.margin,
		}

		local widget = wibox.widget {
			{
				{
					{
						nil,
						{
							{
								{
									w,
									layout   = wibox.layout.fixed.horizontal,
								},
								strategy = 'max',
								width    = dpi(64),
								widget   = wibox.container.constraint,
							},
							valign = 'center',
							halign = 'center',
							layout = wibox.container.place,
						},
						nil,
						layout = wibox.layout.align.horizontal,
					},
					{
						nil,
						{
							text   = 'Night mode',
							align  = 'center',
							widget = wibox.widget.textbox,
						},
						nil,
						layout = wibox.layout.align.horizontal,
						--strategy = 'max',
						--width    = dpi(64),
						--widget   = wibox.container.constraint,
					},
					layout = wibox.layout.align.vertical,
				},
				strategy = 'max',
				forced_width = dpi(32),
				widget   = wibox.container.constraint,
			},
			bg     = beautiful.nord3,
			shape  = rounded_rectangle(dpi(8)),
			shape_border_width = dpi(1),
			shape_border_color = beautiful.nord4,
			widget = wibox.widget.background,
		}

		buttonify {
			button_normal  = beautiful.nord10 or '#5E81AC',
			button_enter   = beautiful.nord9  or '#81A1C1',
			button_press   = beautiful.nord8  or '#88C0D0',
			button_release = beautiful.nord9  or '#81A1C1',
			widget         = w.widget
		}
		w.widget:connect_signal('button::release', function(_,_,_,b)
			if b == 1 then
				awesome.emit_signal('qrlinux::util::night_mode')
			end
		end)

		return(widget)
	end

	qrwidget.music(s)
	qrwidget.night_mode(s, '#854b11')

	local generic_widget = toggle_button {}

	local toggle_button_container = wibox.widget {
		{
			{
				{
					{
						{
							--toggle_button_container_nightmode(), -- A1
							toggle_button { deactivate = 'always' }, -- A1
							toggle_button { deactivate = 'always' }, -- B1
							toggle_button { deactivate = 'always' }, -- C1
							toggle_button { deactivate = 'always' }, -- D1
							toggle_button { deactivate = 'always' }, -- A2
							toggle_button { deactivate = 'always' }, -- B2
							toggle_button { deactivate = 'always' }, -- C2
							toggle_button { deactivate = 'always' }, -- D2
							toggle_button { deactivate = 'always' }, -- A3
							toggle_button { deactivate = 'always' }, -- B3
							toggle_button { deactivate = 'always' }, -- C3
							toggle_button { deactivate = 'always' }, -- D3
							toggle_button { deactivate = 'always' }, -- A4
							toggle_button { deactivate = 'always' }, -- B4
							toggle_button { deactivate = 'always' }, -- C4
							toggle_button { deactivate = 'always' }, -- D4
							homogeneous     = true,
							expand          = true,
							forced_num_cols = 4,
							spacing         = dpi(5),
							layout          = wibox.layout.grid,
						},
						bottom = dpi(16),
						widget = wibox.container.margin,
					},
					{
						s.music_control_widget(dpi(300), dpi(225)),
						strategy = 'max',
						height   = dpi(130),
						widget   = wibox.container.constraint,
					},
					layout  = wibox.layout.align.vertical,
				},
				margins = dpi(16),
				widget  = wibox.container.margin,
			},
			bg                 = beautiful.control_panel_container_bg or beautiful.nord0 or '#2E3440',
			shape              = beautiful.control_panel_container_shape or rounded_rectangle(dpi(20)),
			shape_border_width = beautiful.control_panel_container_shape_width or dpi(1),
			shape_border_color = beautiful.control_panel_container_shape_color or beautiful.nord4 or '#D8DEE9',
			widget             = wibox.container.background,
		},
		top    = dpi(16),
		left   = dpi(16),
		right  = dpi(16),
		widget = wibox.container.margin,
	}
	--toggle_button_container.widget.widget.widget:add_widget_at(toggle_button_container_textbox, 2, 1, 1, 2)

	s.control_panel.control_panel:setup {
		direction = 'east',
		layout    = wibox.layout.fixed.vertical,
		{
			{
				{
					s.control_panel.widget.volume_slider(),
					layout = wibox.layout.fixed.horizontal,
				},
				bg     = beautiful.nord2,
				widget = wibox.container.background,
				layout = wibox.layout.fixed.vertical,
			},
			top    = dpi(16),
			left   = dpi(16),
			right  = dpi(16),
			widget = wibox.container.margin,
		},
		toggle_button_container,
		nil,
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
