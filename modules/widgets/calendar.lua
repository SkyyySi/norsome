local rounded_rectangle = require('rounded_rectangle')
local infobubble        = require('infobubble')

local function calendar_widget(s)
    local arrow_size   = dpi(10)
    local widget_shape = infobubble(dpi(20), arrow_size)

	-- How the widget should look in the wibox / panel
	local calendar_widget_panel_button_text = wibox.widget {
        refresh = 1,
        format  = '%a %b %d, %T',
        widget  = wibox.widget.textclock,
	}

	-- The widget to show in the wibox / panel
	local calendar_widget_panel_button = wibox.widget {
		{
			{
				{
                    {
                        widget = calendar_widget_panel_button_text,
                    },
                    left   = dpi(10),
                    right  = dpi(10),
                    widget = wibox.container.margin
                },
                layout = wibox.layout.align.horizontal
            },
            bg                 = beautiful.button_normal,
            shape_border_width = dpi(1),
            shape_border_color = beautiful.nord4,
            shape              = gears.shape.rounded_bar,
            widget             = wibox.container.background
        },
        margins = dpi(4),
        widget  = wibox.container.margin
    }
	buttonify({ widget = calendar_widget_panel_button.widget })

    calendar_widget_popup_widget = wibox.widget {
        widget = double_border_widget {
            widget = wibox.widget {
                {
                    widget = require('widgets.control_panel.widgets.calendar')
                },
                margins = {
                    top = arrow_size,
                },
                widget = wibox.container.margin,
            },
            shape = widget_shape,
        },
        mode      = 'fixed',
        screen    = s,
        width     = dpi(192),
        height    = dpi(230),
        placement = 'bottom_right',
    }

    calendar_widget_popup = make_widget {
        visible = false,
        widget  = calendar_widget_popup_widget,
        screen  = s,
        shape   = widget_shape,
        mode    = 'popup',
    }

    calendar_widget_panel_button:connect_signal('button::release', function(c, _, _, button)
        if button == 1 then
            center = mouse.current_widget_geometry.x - ((calendar_widget_popup.width or 0) / 2) + ((calendar_widget_panel_button.width or 0) / 2)
            awful.placement.top_left(calendar_widget_popup, { margins = {top = 48, left = center }, parent = s })

            calendar_widget_popup.visible = (not calendar_widget_popup.visible)
        end
    end)

    return(calendar_widget_panel_button)
    --[[
    local s = s or awful.screen.focused()

    s.calendar = wibox {
        ontop     = true,
        type      = 'dialog',
        shape     = infobubble(dpi(20)),--rounded_rectangle(20),
        placement = awful.placement.centered,
        height    = dpi(260),
        width     = dpi(220),
        visible   = false,
        screen    = s,
        bg        = beautiful.nord0 .. '80',
        fg        = beautiful.nord4,
    }

    -- Place it at the center of the screen
    awful.placement.centered(s.calendar)


    local styles = {}
    styles.month = { bg_color = '#00000000', padding = dpi(10) }
    styles.normal  = { shape    = rounded_rectangle(dpi(8)) }
    styles.focus   = { fg_color = (beautiful.nord0 or '#2E3440'),
                       bg_color = (beautiful.nord13 or '#EBCB8B'),
                       markup   = function(t) return '<b>' .. t .. '</b>' end,
                       shape    = rounded_rectangle(dpi(8))
    }
    styles.header  = { bg_color = (beautiful.nord12 or '#D08770'),
                       markup   = function(t) return '<b>' .. t .. '</b>' end,
                       shape    = gears.shape.rounded_bar
    }
    styles.weekday = { fg_color = (beautiful.nord9 or '#81A1C1'),
                       markup   = function(t) return '<b>' .. t .. '</b>' end,
                       shape    = rounded_rectangle(dpi(8))
    }
    function s.decorate_cell(widget, flag, date)
        if flag=='monthheader' and not styles.monthheader then
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
            shape        = props.shape,
            border_color = props.border_color or (beautiful.nord11 or'#B48EAD'),
            border_width = props.border_width or dpi(0),
            fg           = props.fg_color or (beautiful.nord4 or'#D8DEE9'),
            bg           = props.bg_color or default_bg,
            widget       = wibox.container.background
        }
        return ret
    end

    s.cal = wibox.widget {
        date     = os.date('*t'),
        font     = 'Source Code Pro 10',
        fn_embed = s.decorate_cell,
        widget   = wibox.widget.calendar.month
    }

    s.calendar_box_content = {
        s.cal,
        layout = wibox.layout.flex.horizontal
    }

    -- Put its items in a shaped container
    s.calendar:setup {
        {
            {
                {
                    s.calendar_box_content,
                    layout = wibox.layout.flex.horizontal
                },
                top    = dpi(12),
                --left   = dpi(10),
                widget = wibox.container.margin
            },
            halign    = 'center',
            valign    = 'center',
            layout    = wibox.layout.flex.horizontal,
            placement = awful.placement.centered,
            widget    = wibox.container.place,
        },
        shape_border_width = dpi(2),
        shape_border_color = beautiful.nord4,
        shape              = infobubble(dpi(20)), --rounded_rectangle(20),
        widget             = wibox.widget.background,
    }

    s.calendar_button = wibox.widget{
        {{{{
                        refresh = 1,
                        format  = '%a %b %d, %T',
                        widget  = wibox.widget.textclock,
                    },
                    left   = dpi(10),
                    right  = dpi(10),
                    widget = wibox.container.margin
                },
                layout = wibox.layout.align.horizontal
            },
            bg                 = beautiful.button_normal,
            shape_border_width = dpi(1),
            shape_border_color = beautiful.nord4,
            shape              = gears.shape.rounded_bar,
            widget             = wibox.container.background
        },
        margins = dpi(4),
        widget  = wibox.container.margin
    }

    s.calendar_button:connect_signal('button::release', function(c, _, _, button)
        if button == 1 then
            s.calendar.visible = not s.calendar.visible

            center = mouse.current_widget_geometry.x - ((s.calendar.width or 0) / 2) + ((s.calendar_button.width or 0) / 2)
            awful.placement.top_left(s.calendar, { margins = {top = 48, left = center }, parent = s })
        end
    end)

    --awful.placement.top_right(s.calendar, { margins = {top = 48, right = 16}})
    local old_cursor, old_wibox
    s.calendar_button.widget:connect_signal('mouse::enter', function(c)
        c:set_bg(beautiful.button_enter) -- hovered  / nord 2
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand1"
    end)
    s.calendar_button.widget:connect_signal('mouse::leave', function(c)
        c:set_bg(beautiful.button_normal) -- default  / nord 1
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)
    s.calendar_button.widget:connect_signal('button::press',   function(c) c:set_bg(beautiful.button_press)   end) -- pressed  / nord 3
    s.calendar_button.widget:connect_signal('button::release', function(c) c:set_bg(beautiful.button_release) end) -- released / nord 2

    return(s.calendar_button)
    --]]
end

return(calendar_widget)