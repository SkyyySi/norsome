local function make_widget(arg)
	if not arg then arg = {} end
	local prop = {
		widget             = arg.widget,
		mode               = arg.mode   or 'normal', -- 'normal', 'desktop', 'popup' or 'fixed'; normal means no wrapping, desktop means a non-floating wibox, popup means an awful.popup (for use in bars for example) and fixed is like normal but with a fixed size.
		screen             = arg.screen or 'primary',
		bg                 = arg.bg              or beautiful.qrwidget_bg                 or '#2E3440',
		shape              = arg.shape           or beautiful.qrwidget_shape              or rounded_rectangle(dpi(20)),
		shape_border_width = arg.shape_width     or beautiful.qrwidget_shape_border_width or dpi(1),
		shape_border_color = arg.shape_color     or beautiful.qrwidget_shape_border_color or '#D8DEE9',
		width              = arg.width           or beautiful.qrwidget_width              or dpi(100),
		height             = arg.height          or beautiful.qrwidget_heigth             or dpi(100),
		inner_margins      = arg.inner_margins   or beautiful.qrwidget_inner_margins      or 0,
		desktop_margins    = arg.desktop_margins or beautiful.qrwidget_desktop_margins    or { right = dpi(40) },
		placement          = arg.placement       or beautiful.qrwidget_placement          or 'right',
		visible_desktop    = arg.visible         or beautiful.qrwidget_visible_desktop    or true,
		ontop_desktop      = arg.ontop           or beautiful.qrwidget_ontop_desktop      or false,
		visible_popup      = arg.visible         or beautiful.qrwidget_visible_popup      or false,
		ontop_popup        = arg.ontop           or beautiful.qrwidget_ontop_popup        or true,_popup
	}

	if (prop.mode == 'normal') then
		return(prop.widget())
	elseif (prop.mode == 'desktop') then
		local desktop_widget = wibox {
			type    = 'desktop',
			bg      = '#00000000',
			width   = prop.width,
			height  = prop.height,
			visible = prop.visible_desktop,
			ontop   = prop.ontop_desktop,
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
			visible = true,
			ontop   = prop.ontop_popup,
		}
		-- The reason why the widget always gets set to be visibel and only gets hidden below is
		-- theat the size cannot be read if the popup is set to be invisible on creation.
		popup_widget.visible = prop.visible_popup

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