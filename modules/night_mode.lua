local buttonify = require('buttonify')

local function night_mode(s, c)
	local c = c or '#632b00'

	--[[ local night_mode_button_wibox = wibox {
		screen  = s,
		type    = 'utility',
		width   = 100,
		height  = 60,
		opacity = 1,
		ontop   = true,
		visible = true,
	} --]]

	local night_mode_button = wibox.widget {
		{
			{
				{
					widget = wibox.widget.textbox,
					text   = 'Night mode!',
				},
				widget  = wibox.container.margin,
				margins = dpi(4),
			},
			widget             = wibox.container.background,
			bg                 = beautiful.button_normal,
			shape              = gears.shape.rounded_bar,
			shape_border_width = 2,
			shape_border_color = beautiful.nord12,
		},
		widget  = wibox.container.margin,
		margins = dpi(4),
	}
	buttonify({ widget = night_mode_button.widget })

	--[[ night_mode_button_wibox:setup {
		night_mode_button,
		layout = wibox.layout.align.horizontal
	} --]]

	s.night_mode_overlay = wibox {
		screen            = s,
		width             = 1920,
		height            = 1080,
		type              = 'utility',
		bg                = c,
		opacity           = 0.0,
		input_passthrough = true,
		ontop             = true,
		visible           = true,
	}
	s.night_mode_overlay_enabled = false
	s.night_mode_overlay_timer = nil

	function s.night_mode_overlay_fade(t)
		s.night_mode_overlay_enabled = t
		if (s.night_mode_overlay_timer) then s.night_mode_overlay_timer:stop() end
		if (t == true) then
			s.night_mode_overlay_timer = gears.timer {
				timeout   = 0.05,
				call_now  = true,
				autostart = true,
				callback  = function()
					if (s.night_mode_overlay.opacity < 0.1) then
						s.night_mode_overlay.visible = true
						s.night_mode_overlay.opacity = (s.night_mode_overlay.opacity + 0.01)
					end
				end
			}
		elseif (t == false) then
			s.night_mode_overlay_timer = gears.timer {
				timeout   = 0.05,
				call_now  = true,
				autostart = true,
				callback  = function()
					if (s.night_mode_overlay.opacity > 0) then
						s.night_mode_overlay.opacity = (s.night_mode_overlay.opacity - 0.01)
					elseif (s.night_mode_overlay.opacity <= 0.001) then
						s.night_mode_overlay.visible = false
					end
				end
			}
		end
	end

	night_mode_button:connect_signal('button::press', function(_,_,_,b)
		if (b == 1) then
			awesome.emit_signal('qrlinux::util::night_mode')
			--awful.screen.connect_for_each_screen(function(s)
			--	--s.night_mode_overlay.visible = (not s.night_mode_overlay.visible)
			--	s.night_mode_overlay_enabled = (not s.night_mode_overlay_enabled)
			--	s.night_mode_overlay_fade(s.night_mode_overlay_enabled)
			--end)
		end
	end)

	return(night_mode_button)
end

-- This code needs to be outside of that function, since otherwise,
-- a connection would get established for each screen, which is not
-- just not necessery but also prevents it from working at all
-- with an even amount of connected monitors.
awesome.connect_signal('qrlinux::util::night_mode', function()
	awful.screen.connect_for_each_screen(function(s)
		s.night_mode_overlay_enabled = (not s.night_mode_overlay_enabled)
		s.night_mode_overlay_fade(s.night_mode_overlay_enabled)
	end)
end)

return(night_mode)