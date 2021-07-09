local function get_titlebars()
	client.connect_signal('request::titlebars', function(c)
		local bg_color = '#353C4A'

		if (c == client.focus) then
			bg_color = beautiful.bg_focus
		end

		-- buttons for the titlebar
		local buttons = gears.table.join(
			awful.button({ }, 1, function()
				c:emit_signal('request::activate', 'titlebar', {raise = true})
				awful.mouse.client.move(c)
			end),
			awful.button({ }, 3, function()
				c:emit_signal('request::activate', 'titlebar', {raise = true})
				awful.mouse.client.resize(c)
			end)
		)

		c.top_titlebar = awful.titlebar(c, {
			size           = (beautiful.titlebar_size or dpi(28)) + (beautiful.border_width or dpi(2)),
			enable_tooltip = false,
			position       = 'top',
			bg             = '#00000030', -- transparency; may conflict with transparent titlebars by darkening them, but this makes shadows basically seamless.
		})

		c.top_titlebar.widget = {
			{
				{
					{
						{
							{
								{ -- Left
									wibox.widget.separator { forced_width = dpi(6), orientation = 'horizontal', visible = true, opacity = 0 },
									awful.titlebar.widget.iconwidget(c),
									awful.titlebar.widget.floatingbutton (c),
									awful.titlebar.widget.stickybutton   (c),
									awful.titlebar.widget.ontopbutton    (c),
									layout  = wibox.layout.fixed.horizontal
								},
								{ -- Middle
									{ -- Title
										align  = 'center',
										font   = 'Source Sans Pro bold 12',
										widget = awful.titlebar.widget.titlewidget(c)
									},
									buttons = buttons,
									layout  = wibox.layout.flex.horizontal
								},
								{ -- Right
									awful.titlebar.widget.minimizebutton (c),
									awful.titlebar.widget.maximizedbutton(c),
									awful.titlebar.widget.closebutton    (c),
									layout = wibox.layout.fixed.horizontal
								},
								layout = wibox.layout.align.horizontal
							},
							shape = function(cr,w,h)
								gears.shape.partially_rounded_rect(cr,w,h, true, true, false, false, (beautiful.titlebar_radius or dpi(20)))
							end,
							bg     = bg_color,
							widget = wibox.container.background
						},
						top    = (beautiful.border_width / 2) or dpi(1),
						left   = (beautiful.border_width / 2) or dpi(1),
						right  = (beautiful.border_width / 2) or dpi(1),
						widget = wibox.container.margin
					}, --]]
					shape = function(cr,w,h)
						gears.shape.partially_rounded_rect(cr,w,h, true, true, false, false, (beautiful.titlebar_radius or dpi(20)))
					end,
					bg     = c.border_color,
					widget = wibox.container.background
				},
				top    = (beautiful.border_width / 2) or dpi(1),
				left   = (beautiful.border_width / 2) or dpi(1),
				right  = (beautiful.border_width / 2) or dpi(1),
				widget = wibox.container.margin
			},
			shape = function(cr,w,h)
				gears.shape.partially_rounded_rect(cr,w,h, true, true, false, false, (beautiful.titlebar_radius or dpi(20)))
			end,
			bg     = beautiful.border_outer or '#2E3440',
			widget = wibox.container.background
		}

		-- These are your "borders"
		local left_titlebar = awful.titlebar(c, {
			size            = beautiful.border_width or dpi(2),
			enable_tooltip  = false,
			position        = 'left',
			bg              = c.border_color
		})
		left_titlebar.widget = {
			{
				{
					{
						left   = (beautiful.border_width / 2) or dpi(1),
						widget = wibox.container.margin
					},
					bg     = c.border_color,
					widget = wibox.container.background
				},
				left   = (beautiful.border_width / 2) or dpi(1),
				widget = wibox.container.margin
			},
			bg     = beautiful.border_outer or '#2E3440',
			widget = wibox.container.background
		}

		local right_titlebar = awful.titlebar(c, {
			size            = beautiful.border_width or dpi(2),
			enable_tooltip  = false,
			position        = 'right',
			bg              = c.border_color
		})
		right_titlebar.widget = {
			{
				{
					{
						right  = (beautiful.border_width / 2) or dpi(1),
						widget = wibox.container.margin
					},
					bg     = c.border_color,
					widget = wibox.container.background
				},
				right  = (beautiful.border_width / 2) or dpi(1),
				widget = wibox.container.margin
			},
			bg     = beautiful.border_outer or '#2E3440',
			widget = wibox.container.background
		}

		local bottom_titlebar = awful.titlebar(c, {
			size            = beautiful.border_width or dpi(2),
			enable_tooltip  = false,
			position        = 'bottom',
			bg              = c.border_color
		})
		bottom_titlebar.widget = {
			{
				{
					{
						bottom = (beautiful.border_width / 2) or dpi(1),
						left   = (beautiful.border_width / 2) or dpi(1),
						right  = (beautiful.border_width / 2) or dpi(1),
						widget = wibox.container.margin
					},
					bg     = c.border_color,
					widget = wibox.container.background
				},
				bottom = (beautiful.border_width / 2) or dpi(1),
				left   = (beautiful.border_width / 2) or dpi(1),
				right  = (beautiful.border_width / 2) or dpi(1),
				widget = wibox.container.margin
			},
			bg     = beautiful.border_outer or '#2E3440',
			widget = wibox.container.background
		}

		--[[
		local bottom_titlebar = awful.titlebar(c, {
			size           = beautiful.titlebar_size or dpi(28),
			enable_tooltip = false,
			position       = 'bottom',
		})

		bottom_titlebar:setup {
			{ -- Left
				awful.titlebar.widget.iconwidget(c),
				buttons = buttons,
				layout  = wibox.layout.fixed.horizontal
			},
			{ -- Middle
				{ -- Title
					align  = 'center',
					font   = 'Source Sans Pro bold 12',
					widget = awful.titlebar.widget.titlewidget(c)
				},
				buttons = buttons,
				layout  = wibox.layout.flex.horizontal
			},
			{ -- Right
				awful.titlebar.widget.floatingbutton (c),
				awful.titlebar.widget.stickybutton   (c),
				awful.titlebar.widget.ontopbutton    (c),
				--awful.titlebar.widget.minimizebutton (c),
				--awful.titlebar.widget.maximizedbutton(c),
				awful.titlebar.widget.closebutton    (c),
				layout = wibox.layout.fixed.horizontal
			},
			layout = wibox.layout.align.horizontal
		}
		--]]
	end)
end

return(get_titlebars)