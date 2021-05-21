function control_panel_widget(s)
    s.widget_volume_icon   = wibox.widget {
        {
            font   = 'Source Code Pro 16',
            text   = ' 🔊 ',
            widget = wibox.widget.textbox,
        },
        bg     = '#444444',
        shape  = gears.shape.circle,
        widget = wibox.container.background,
    }

    local volume_slider = wibox.widget {
        bar_shape           = gears.shape.rounded_rect,
        bar_height          = 4,
        bar_color           = '#88c0d0',
        handle_color        = '#81a1c1',
        handle_shape        = gears.shape.circle,
        handle_border_color = '#eceff4',
        handle_border_width = 2,
        value               = 50,
        minimum             = 0,
        maximum             = 100,
        widget              = wibox.widget.slider,
    }

    s.widget_volume_slider = wibox.widget {
        {
            {
                {
                    volume_slider,
                    layout = wibox.layout.align.horizontal,
                },
                left   = 15,
                right  = 15,
                widget = wibox.container.margin,
            },
            bg     = '#555555',
            shape  = rounded_rectangle(999),
            widget = wibox.container.background,
        },
        strategy = 'exact',
        width    = 300,
        height   = 60,
        widget = wibox.container.constraint
    }

    local old_cursor, old_wibox
    volume_slider:connect_signal("mouse::enter", function(c)
        c:set_handle_color('#88c0d0') -- hovered / nord 3
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand1"
    end)
    volume_slider:connect_signal("mouse::leave", function(c)
        c:set_handle_color('#81a1c1') -- default / nord 2
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    volume_slider:connect_signal("button::press",   function(c)
        if button == 1 then
            c:set_handle_color('#5e81ac') -- pressed  / nord 4
        end
    end)
    volume_slider:connect_signal("button::release", function(c) c:set_handle_color('#81a1c1') end) -- released / nord 3

    s.control_panel = awfulwibar {
        bg       = '#222',
        position = 'right',
        stretch  = true,
        visible  = false,
        ontop    = true,
        screen   = s,
        width    = 400,
        layout = wibox.layout.flex.vertical,
    }

    s.control_panel:setup {
        direction = "east",
        layout    = wibox.layout.align.vertical,
        {
            s.widget_volume_icon,
            layout = wibox.layout.fixed.vertical,
        },
        {
            s.widget_volume_icon,
            layout = wibox.layout.flex.vertical,
        },
        {
            {
                {
                    {
                        s.widget_volume_icon,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    {
                        s.widget_volume_slider,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    bg     = '#606060',
                    widget = wibox.container.background,
                    layout = wibox.layout.align.horizontal,
                },
                layout = wibox.layout.fixed.horizontal,
            },
        margins = 10,
        widget  = wibox.container.margin,
        },
    }

    s.control_panel_button = wibox.widget{
        {{{
                    font = 'Source Code Pro Black 22',
                    text = '◀',
                    widget = wibox.widget.textbox,
                },
                top = 4, bottom = 4, left = 8, right = 8,
                widget = wibox.container.margin,
            },
            bg = '#3b4252',
            shape_border_width = 1,
            shape_border_color = '#d8dee9',
            shape = rounded_rectangle(20),
            widget = wibox.container.background,
        },
        margins = 4,
        widget = wibox.container.margin,
    }

    if s.control_panel.visible == false then
        s.control_panel_button.widget.widget.widget.text = '▶'
    else
        s.control_panel_button.widget.widget.widget.text = '◀'
    end

    local old_cursor, old_wibox
    s.control_panel_button.widget:connect_signal("mouse::enter", function(c)
        c:set_bg('#434c5e') -- hovered  / nord 2
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand1"
    end)
    s.control_panel_button.widget:connect_signal("mouse::leave", function(c)
        c:set_bg('#3b4252') -- default  / nord 1
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    s.control_panel_button.widget:connect_signal("button::press",   function(c) c:set_bg('#4c566a') end) -- pressed  / nord 3
    s.control_panel_button.widget:connect_signal("button::release", function(c)
        c:set_bg('#434c5e') -- released / nord 2
        if s.control_panel.visible == false then
            s.control_panel.visible = true
            s.control_panel_button.widget.widget.widget.text = '▶'
        else
            s.control_panel.visible = false
            s.control_panel_button.widget.widget.widget.text = '◀'
        end
    end)

    return(s.control_panel_button)
end

return(control_panel_widget)