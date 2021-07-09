local function calendar_widget()
	local styles = {}
	styles.month = {
		bg_color = gears.color.transparent,
		padding  = dpi(10) }
	styles.normal = {
		shape = rounded_rectangle(dpi(8))
	}
	styles.focus = {
		fg_color = (beautiful.nord0 or '#2E3440'),
		bg_color = (beautiful.nord13 or '#EBCB8B'),
		markup   = function(t) return '<b>' .. t .. '</b>' end,
		shape    = rounded_rectangle(dpi(8))
	}
	styles.header  = {
		bg_color = (beautiful.nord12 or '#D08770'),
		markup   = function(t) return '<b>' .. t .. '</b>' end,
		shape    = gears.shape.rounded_bar
	}
	styles.weekday = {
		fg_color = (beautiful.nord9 or '#81A1C1'),
		markup   = function(t) return '<b>' .. t .. '</b>' end,
		shape    = rounded_rectangle(dpi(8))
	}

	local function decorate_cell(widget, flag, date)
		if (flag == 'monthheader' and not styles.monthheader) then
			flag = 'header'
		end

		local props = styles[flag] or {}
		if props.markup and widget.get_text and widget.set_markup then
			widget:set_markup(props.markup(widget:get_text()))
		end

		-- Change bg color for weekends
		local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
		local weekday = tonumber(os.date('%w', os.time(d)))
		local default_bg = (weekday==0 or weekday==6) and (beautiful.nord2 or '#434C5E') or (beautiful.nord1 or '#3B4252')
		local ret = wibox.widget {
			{
				widget,
				margins = (props.padding or dpi(2)) + (props.border_width or dpi(0)),
				widget  = wibox.container.margin
			},
			bg           = props.bg_color     or default_bg,
			fg           = props.fg_color     or (beautiful.nord4 or'#D8DEE9'),
			shape        = props.shape,
			border_color = props.border_color or (beautiful.nord11 or'#B48EAD'),
			border_width = props.border_width or dpi(0),
			widget       = wibox.container.background
		}
		return(ret)
	end

	local main = {}

	main.main_widget = wibox.widget {
		date     = os.date('*t'),
		font     = 'Source Code Pro 10',
		fn_embed = decorate_cell,
		widget   = wibox.widget.calendar.month
	}

	return(main.main_widget)
end

return(calendar_widget)