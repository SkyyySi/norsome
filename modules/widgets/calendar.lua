local rounded_rectangle = require('rounded_rectangle')
local infobubble        = require('infobubble')

function calendar_widget(s)
    local s = s or awful.screen.focused()

    s.calendar = wibox {
        ontop     = true,
        type      = 'dialog',
        shape     = infobubble(dpi(20)),--rounded_rectangle(20),
        placement = awful.placement.centered,
        height    = dpi(240),
        width     = dpi(190),
        visible   = false,
        screen    = s,
    }

    -- Place it at the center of the screen
    awful.placement.centered(s.calendar)

    -- Set bg and fg
    s.calendar.bg = beautiful.nord0 .. '80'
    s.calendar.fg = beautiful.nord4

    s.cal = wibox.widget.calendar.month(os.date('*t'), 'Source Code Pro 12')
    s.calendar_box_content = {
        s.cal,
        layout = wibox.layout.align.horizontal
    }

    -- Put its items in a shaped container
    s.calendar:setup {
        {
            {
                {
                    s.calendar_box_content,
                    layout = wibox.layout.flex.horizontal
                },
                top    = dpi(32),
                left   = dpi(10),
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
end

return(calendar_widget)