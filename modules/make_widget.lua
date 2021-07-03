local function make_widget(arg)
	if not arg then arg = {} end
	local prop = {}
	prop.widget = arg.widget
	prop.mode   = arg.mode   or 'normal' -- 'normal', 'desktop', 'popup' or 'fixed'; normal means no wrapping, desktop means a non-floating wibox, popup means an awful.popup (for use in bars for example) and fixed is like normal but with a fixed size.
	prop.screen = arg.screen or 'primary'
	prop.bg                 = arg.bg              or beautiful.qrwidget_bg                 or '#2E3440'
	prop.shape              = arg.shape           or beautiful.qrwidget_shape              or rounded_rectangle(dpi(20))
	prop.shape_border_width = arg.shape_width     or beautiful.qrwidget_shape_border_width or dpi(1)
	prop.shape_border_color = arg.shape_color     or beautiful.qrwidget_shape_border_color or '#D8DEE9'
	prop.width              = arg.width           or beautiful.qrwidget_width              or dpi(100)
	prop.height             = arg.height          or beautiful.qrwidget_heigth             or dpi(100)
	prop.inner_margins      = arg.inner_margins   or beautiful.qrwidget_inner_margins      or 0
	prop.desktop_margins    = arg.desktop_margins or beautiful.qrwidget_desktop_margins    or { right = dpi(40) }
	prop.placement          = arg.placement       or beautiful.qrwidget_placement          or 'right'

	if (prop.mode == 'normal') then
		return(prop.widget())
	elseif (prop.mode == 'desktop') then
		local desktop_widget = wibox {
			type    = 'desktop',
			bg      = '#00000000',
			width   = prop.width,
			height  = prop.height,
			visible = true,
			ontop   = false,
			screen  = prop.screen,
			shape   = prop.shape,
		}

		desktop_widget:setup {
			{
				{
					{
						{
							widget = prop.widget(),
						},
						margins = prop.inner_margins,
						widget  = wibox.container.margin,
					},
					bg                 = prop.bg,
					shape              = prop.shape,
					shape_border_width = prop.shape_border_width,
					shape_border_color = prop.shape_border_color,
					widget             = wibox.container.background,
				},
				margins = prop.shape_border_width,
				widget  = wibox.container.margin,
			},
			bg                 = prop.shape_border_color,
			shape              = prop.shape,
			shape_border_width = prop.shape_border_width,
			shape_border_color = prop.bg,
			widget             = wibox.container.background,
		}

		-- Input to load() must be global. To avoid any possible conflicts, there are random characters at the beginning.
		_BSFHBDSFHZEBSE_PLACEMNET_FUNCTION_TEMP_WIDGET = desktop_widget
		_BSFHBDSFHZEBSE_PLACEMNET_FUNCTION_TEMP_MARGIN = prop.desktop_margins
		placement_function = load('print(awful.placement.'..prop.placement..'(_PLACEMNET_FUNCTION_TEMP_WIDGET, { margins = _PLACEMNET_FUNCTION_TEMP_MARGIN }))')
		placement_function()
		_BSFHBDSFHZEBSE_PLACEMNET_FUNCTION_TEMP_WIDGET = nil
		_BSFHBDSFHZEBSE_PLACEMNET_FUNCTION_TEMP_MARGIN = nil
		--awful.placement.bottom_right(desktop_widget, {
		--	margins = prop.desktop_margins
		--})
	elseif (prop.mode == 'popup') then
		local popup_widget = awful.popup {
			widget = wibox.widget {
				{
					{
						{
							widget = prop.widget,
						},
						strategy = 'max',
						layout   = wibox.container.constraint,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				layout = wibox.layout.fixed.vertical,
			},
			type    = 'popup_menu',
			bg      = '#00000000',
			screen  = prop.screen,
			shape   = prop.shape,
			visible = false,
			ontop   = true,
		}

		return(popup_widget)
	elseif (prop.mode == 'fixed') then
		local fixed_widget = wibox.widget {
			{
				{
					{
						widget = prop.widget
					},
					strategy = 'max',
					width    = prop.width,
					height   = prop.height,
					layout   = wibox.container.constraint,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			layout = wibox.layout.fixed.vertical,
		}

		return(fixed_widget)
	end
end

return(make_widget)