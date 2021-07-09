local rounded_rectangle = require('rounded_rectangle')
local buttonify         = require('buttonify')
local toggle_button     = require('widgets.control_panel.toggle_button')
require('signals.network')

local function control_panel_widget(s)
	local control_panel_setting = {}
	control_panel_setting.widget = {}
	control_panel_setting.width  = dpi(400)

	local volume_slider = require('widgets.control_panel.widgets.volume')
	local calendar      = require('widgets.control_panel.widgets.calendar')

	local control_panel = awful.wibar {
		bg       = beautiful.control_panel_bg,
		position = 'right',
		stretch  = true,
		visible  = false,
		ontop    = true,
		screen   = s,
		width    = control_panel_setting.width,
	}

	qrwidget.music(s)
	qrwidget.night_mode(s, '#854b11')

	local toggle_mic_shell_script = [[sh -c '
		for i in $(pactl list sources short | awk "{print \$2}"); do
			pactl set-source-mute "${i}" toggle
		done
	']]

	local mic_status_shell_script = [[sh -c '
	if [ "$(pacmd list-sources | command grep "mute" | awk "NR==1{print \$2}" 2> /dev/null)" = "yes" ]; then
		printf "false"
	else
		printf "true"
	fi
	']]

	toggle_button_buttons = wibox.widget {
		-- Please refer to toggle_button.lua if you want to see the available options.
		toggle_button {
			icon       = beautiful.icon.night_mode,
			title      = 'Night mode',
			deactivate = 'always',
			active     = false,
			lclick     = function()
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
		toggle_button {
			icon       = beautiful.icon.microphone,
			title      = 'Microphone',
			deactivate = 'signals',
			active     = true,
			control_signal = 'qrlinux::media::microphone_status',
			lclick     = function()
				awful.spawn(toggle_mic_shell_script)
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

	gears.timer {
		autostart = true,
		call_now  = true,
		timeout   = 1,
		callback  = function()
			awful.spawn.easy_async(mic_status_shell_script, function(mic_status)
				if (mic_status == 'true\n') then
					awesome.emit_signal('qrlinux::media::microphone_status', true)
				else
					awesome.emit_signal('qrlinux::media::microphone_status', false)
				end
			end)
		end
	}

	local function control_panel_widget_wrapper(w, m)
		return({
			double_border_widget({ widget = w, margins = m }),
			top    = dpi(16),
			widget = wibox.container.margin,
		})
	end

	local toggle_button_container = wibox.widget {
		{
			toggle_button_buttons,
			bottom = dpi(16),
			widget = wibox.container.margin,
		},
		{
			s.music_control_widget((control_panel_setting.width - dpi(80)), dpi(225)),
			strategy = 'max',
			height   = dpi(130),
			widget   = wibox.container.constraint,
		},
		layout = wibox.layout.fixed.vertical,
	}

	local notification_container = require('widgets.control_panel.widgets.notification_center')

	local control_panel_page = {}
	control_panel_page.current = 1
	control_panel_page.switcher_arrow = wibox.widget {
		{
				{
					margins = dpi(8),
					widget  = wibox.container.margin,
				},
				bg     = beautiful.control_panel_fg or '#D8DEE9',
				shape  = gears.shape.isosceles_triangle,
				widget = wibox.container.background,
			},
			top    = dpi(12),
			bottom = dpi(14),
			left   = dpi(12),
			right  = dpi(12),
			widget = wibox.container.margin,
	}
	control_panel_page.current_text = wibox.widget {
		font   = beautiful.control_panel_page_font or 'Source Sand Pro 16',
		markup = ('Current page: <b>' .. tostring(control_panel_page.current) .. '</b>'),
		align  = 'center',
		valign = 'center',
		widget = wibox.widget.textbox,
	}

	control_panel_page.left_arrow = wibox.widget {
		{
			{
				widget = control_panel_page.switcher_arrow,
			},
			bg                 = beautiful.button_normal or '#3B4252',
			shape              = gears.shape.circle,
			shape_border_width = beautiful.button_border_width or dpi(1),
			shape_border_color = beautiful.button_border_color or '#D8DEE9',
			widget             = wibox.container.background,
		},
		direction = 'east',
		widget    = wibox.container.rotate,
	}
	buttonify { widget = control_panel_page.left_arrow.widget }
	control_panel_page.left_arrow:connect_signal('button::release', function()
		control_panel_page.current = (control_panel_page.current - 1)
		control_panel_page.current_text.markup = ('Current page: <b>' .. tostring(control_panel_page.current) .. '</b>')
	end)

	control_panel_page.right_arrow = wibox.widget {
		{
			{
				widget = control_panel_page.switcher_arrow,
			},
			bg                 = beautiful.button_normal or '#3B4252',
			shape              = gears.shape.circle,
			shape_border_width = beautiful.button_border_width or dpi(1),
			shape_border_color = beautiful.button_border_color or '#D8DEE9',
			widget             = wibox.container.background,
		},
		direction = 'west',
		widget    = wibox.container.rotate,
	}
	buttonify { widget = control_panel_page.right_arrow.widget }
	control_panel_page.right_arrow:connect_signal('button::release', function()
		control_panel_page.current = (control_panel_page.current + 1)
		control_panel_page.current_text.markup = ('Current page: <b>' .. tostring(control_panel_page.current) .. '</b>')
	end)

	control_panel_page.switcher = wibox.widget {
		control_panel_page.left_arrow,
		control_panel_page.current_text,
		control_panel_page.right_arrow,
		layout = wibox.layout.align.horizontal
	}

	control_panel_page.page1 = wibox.widget {
		{
			{
				control_panel_widget_wrapper(volume_slider(), 0),
				control_panel_widget_wrapper(toggle_button_container, 16),
				layout = wibox.layout.fixed.vertical,
			},
			control_panel_widget_wrapper(notification_container),
			--control_panel_widget_wrapper(calendar('normal'), 0),
			layout = wibox.layout.align.vertical,
		},
		bottom = dpi(16),
		left   = dpi(16),
		right  = dpi(16),
		widget = wibox.container.margin,
	}

	control_panel:setup {
		{
			control_panel_widget_wrapper(control_panel_page.switcher, 16),
			left   = dpi(16),
			right  = dpi(16),
			widget = wibox.container.margin,
		},
		control_panel_page.page1,
		layout = wibox.layout.align.vertical,
		--widget = control_panel_page_switcher,
	}

	local control_panel_button_shape = wibox.widget {
		{
			{
				{
					margins = dpi(8),
					widget  = wibox.container.margin,
				},
				bg     = beautiful.nord4,
				shape  = function(cr,w,h) gears.shape.isosceles_triangle(cr, w, h) end,
				widget = wibox.container.background,
			},
			direction = 'east',
			widget    = wibox.container.rotate,
		},
		top    = dpi(4),
		bottom = dpi(4),
		left   = dpi(0),
		right  = dpi(2),
		widget = wibox.container.margin,
	}

	local control_panel_button = wibox.widget{
		{
			{
				{
					widget = control_panel_button_shape,
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

	local function set_bar_visibility(t)
		if t then
			control_panel.visible                       = true
			control_panel_button_shape.widget.direction = 'west'
			control_panel_button_shape.left             = dpi(2)
			control_panel_button_shape.right            = dpi(0)
		else
			control_panel.visible                       = false
			control_panel_button_shape.widget.direction = 'east'
			control_panel_button_shape.left             = dpi(0)
			control_panel_button_shape.right            = dpi(2)
		end
	end

	set_bar_visibility(false)

	buttonify({widget = control_panel_button.widget})
	control_panel_button.widget:connect_signal('button::release', function(c)
		set_bar_visibility(not control_panel.visible)
	end)

	return(control_panel_button)
end

return(control_panel_widget)