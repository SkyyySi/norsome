local rounded_rectangle = require('rounded_rectangle')
local buttonify         = require('buttonify')
local toggle_button     = require('widgets.control_panel.toggle_button')
require('signals.network')

local control_panel_widget
function control_panel_widget(s)
    --local s = s or awful.screen.focused()
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

	qrwidget.music(s)
	qrwidget.night_mode(s, '#854b11')

	local toggle_button_buttons = wibox.widget {
		-- Please refer to toggle_button.lua if you want to see the available options.
		toggle_button {
			icon          = beautiful.icon.night_mode,
			title         = 'Night mode',
			deactivate    = 'always',
			active        = false,
			lclick        = function()
				awesome.emit_signal('qrlinux::util::night_mode')
			end,
		},
		toggle_button {
			icon           = beautiful.icon.web,
			title          = 'Wifi',
			deactivate     = 'signal',
			control_signal = 'qrlinux::wifi::enabled',
			lclick         = function()
				awesome.emit_signal('qrlinux::wifi::toggle')
			end,
		},
		-- Toggle buttons can also be used as shortcuts, for example like this:
		--toggle_button {
		--	icon   = beautiful.icon.terminal,
		--	lclick = function()
		--		awful.spawn(terminal or 'xterm')
		--	end,
		--},
		homogeneous     = true,
		expand          = true,
		forced_num_cols = 4,
		spacing         = dpi(5),
		layout          = wibox.layout.grid,
	}

	local toggle_button_container = wibox.widget {
		{
			{
				{
					{
						{
							{
								toggle_button_buttons,
								bottom = dpi(16),
								widget = wibox.container.margin,
							},
							{
								s.music_control_widget((s.control_panel.width - dpi(80)), dpi(225)),
								strategy = 'max',
								height   = dpi(130),
								widget   = wibox.container.constraint,
							},
							layout = wibox.layout.align.vertical,
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
				margins = dpi(1),
				widget  = wibox.container.margin,
			},
			bg                 = beautiful.control_panel_container_shape_color or beautiful.nord4 or '#D8DEE9',
			shape              = beautiful.control_panel_container_shape or rounded_rectangle(dpi(20)),
			shape_border_width = beautiful.control_panel_container_shape_width or dpi(1),
			shape_border_color = beautiful.control_panel_container_shape_color_outer or beautiful.nord0 or '#2E3440',
			widget             = wibox.container.background,
		},
		top    = dpi(16),
		left   = dpi(16),
		right  = dpi(16),
		widget = wibox.container.margin,
	}
	--toggle_button_container.widget.widget.widget:add_widget_at(toggle_button_container_textbox, 2, 1, 1, 2)

	naughty.expiration_paused = true
	naughty.expirationpause   = naughty.expiration_paused -- Workaround for the button erroring out when naughty.expiration_paused is true.
	local notification_container = wibox.widget {
		-- Add a button to dismiss all notifications, because why not.
		{
			{
				text   = 'Dismiss all',
				align  = 'center',
				valign = 'center',
				widget = wibox.widget.textbox,
			},
			buttons = gears.table.join(
				awful.button({ }, 1, function()
					naughty.expiration_paused = false
					naughty.destroy_all_notifications()
					naughty.expiration_paused = naughty.expirationpause
				end)
			),
			forced_width       = dpi(75),
			shape              = gears.shape.rounded_bar,
			shape_border_width = dpi(1),
			shape_border_color = beautiful.bg_highlight,
			widget = wibox.container.background,
		},
		{
			base_layout = wibox.widget {
				spacing_widget = wibox.widget {
					orientation = 'horizontal',
					span_ratio  = 1,
					widget      = wibox.widget.separator,
				},
				forced_height = dpi(30),
				spacing       = dpi(3),
				layout        = wibox.layout.flex.vertical,
			},
			widget_template = {
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
								span_ratio  = 0.9,
								widget      = wibox.widget.separator,
							},
							spacing = dpi(3),
							layout  = wibox.layout.flex.horizontal,
						},
						widget = naughty.list.widgets,
					},
					layout = wibox.layout.align.horizontal,
				},
				spacing    = 0,
				fill_space = false,
				layout     = wibox.layout.fixed.horizontal,
			},
			widget = naughty.list.notifications,
		},
		layout = wibox.layout.align.vertical,
	}

	s.control_panel.control_panel:setup {
		direction = 'east',
		layout    = wibox.layout.align.vertical,
		{
			{
				{
					{
						{
							s.control_panel.widget.volume_slider(),
							layout = wibox.layout.fixed.horizontal,
						},
						margins = dpi(1),
						widget  = wibox.container.margin,
					},
					bg                 = beautiful.nord0,
					shape              = rounded_rectangle(dpi(21)),
					shape_border_width = dpi(1),
					shape_border_color = beautiful.nord0,
					widget             = wibox.container.background,
				},
				top    = dpi(16),
				left   = dpi(16),
				right  = dpi(16),
				widget = wibox.container.margin,
			},
			toggle_button_container,
			layout = wibox.layout.fixed.vertical,
		},
		{
			{
				{
					{
						{
							{
								widget = notification_container,
							},
							margins = dpi(16),
							widget  = wibox.container.margin,
						},
						bg                 = beautiful.nord0,
						shape              = rounded_rectangle(dpi(20)),
						shape_border_width = dpi(1),
						shape_border_color = beautiful.nord4,
						widget             = wibox.container.background,
					},
					margins = dpi(1),
					widget  = wibox.container.margin,
				},
				bg                 = beautiful.control_panel_container_shape_color or beautiful.nord4 or '#D8DEE9',
				shape              = beautiful.control_panel_container_shape or rounded_rectangle(dpi(20)),
				shape_border_width = beautiful.control_panel_container_shape_width or dpi(1),
				shape_border_color = beautiful.control_panel_container_shape_color_outer or beautiful.nord0 or '#2E3440',
				widget             = wibox.container.background,
			},
			margins = dpi(16),
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
