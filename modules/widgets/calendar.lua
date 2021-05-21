local rounded_rectangle = require('rounded_rectangle')

function calendar_widget(s)
    s.calendar = wibox({
        ontop     = true,
        type      = "dialog",
        shape     = rounded_rectangle(20),
        placement = awful.placement.centered,
        height    = 300,
        width     = 190,
        visible   = false,
        screen    = s,
    })

    -- Place it at the center of the screen
    awful.placement.centered(s.calendar)

    -- Set bg and fg
    s.calendar.bg = "#2e344080"
    s.calendar.fg = "#d8dee9"

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
                left = 10,
                widget = wibox.container.margin
            },
            halign    = 'center',
            valign    = 'center',
            layout    = wibox.layout.flex.horizontal,
            placement = awful.placement.centered,
            widget    = wibox.container.place,
        },
        shape_border_width = 2,
        shape_border_color = '#FFFFFF',
        shape  = rounded_rectangle(20),
        widget = wibox.widget.background,
    }

    s.calendar_button = wibox.widget{
        {{{{
                        widget = wibox.widget.textclock('%a %b %d, %H:%M'),
                    },
                    left = 10, right = 10,
                    widget = wibox.container.margin
                },
                layout = wibox.layout.align.horizontal
            },
            bg = '#4C566A',
            shape_border_width = 1,
            shape_border_color = '#d8dee9',
            shape = rounded_rectangle(20),
            widget = wibox.container.background
        },
        margins = 4,
        widget = wibox.container.margin
    }

    s.calendar_button:connect_signal("button::release", function(c, _, _, button) 
        if button == 1 then
            s.calendar.visible = not s.calendar.visible
        end
    end)

    awful.placement.top_right(s.calendar, { margins = {top = 48, right = 16}})

    return(s.calendar_button)
end

return(calendar_widget)