local rounded_rectangle = require('rounded_rectangle')
local buttonify         = require('buttonify')

local control_panel_widget
function control_panel_widget(s)
    --local xresources = require("beautiful.xresources")
    --local dpi        = xresources.apply_dpi
    local width = 400

    -- Read the current pulse audio volume using the pamixer command
    function s.get_volume(f)
        awful.spawn.easy_async_with_shell('pamixer --get-volume', function(vol)
            local volume = tonumber(vol)
            f(volume)
        end)
    end

    --local get_volume_cmd = 'bash -c "while true; do pamixer --get-volume; sleep 0.1; done"'
    --awful.spawn.easy_async({"pkill", "--full", "--uid", os.getenv("USER"), "^pamixer --get-volume"}, function()
    --    awful.spawn.with_line_callback(get_volume_cmd, {stdout = function(out)
    --            awesome.emit_signal('qrlinux::media::get_volume', tonumber(out))
    --        end
    --    })
    --end)

    s.widget_volume_icon   = wibox.widget {
        {
            font   = 'Source Code Pro 16',
            text   = ' 🔊 ',
            widget = wibox.widget.textbox,
        },
        bg     = '#444444',
        shape  = rounded_rectangle(20),
        widget = wibox.container.background,
    }

    s.volume_slider = wibox.widget {
        bar_shape           = gears.shape.rounded_bar,
        bar_height          = 4,
        bar_color           = beautiful.nord8,
        handle_color        = beautiful.nord4,
        handle_shape        = gears.shape.circle,
        handle_border_color = beautiful.nord3,
        handle_border_width = 2,
        value               = 50,
        minimum             = 0,
        maximum             = 100,
        widget              = wibox.widget.slider,
    }

    s.get_volume(function(v)
        --naughty.notify({text = tostring(v)})
        s.volume_slider = wibox.widget {
            bar_shape           = gears.shape.rounded_bar,
            bar_height          = 4,
            bar_color           = beautiful.nord8,
            handle_color        = beautiful.nord4,
            handle_shape        = gears.shape.circle,
            handle_border_color = beautiful.nord3,
            handle_border_width = 2,
            value               = v,
            minimum             = 0,
            maximum             = 100,
            widget              = wibox.widget.slider,
        }
    end)

    s.volume_slider:connect_signal('property::value', function(c)
        awful.spawn.with_shell('pamixer --set-volume ' .. c.value)
    end)

    --awesome.connect_signal('qrlinux::media::get_volume', function(volume)
    --    s.volume_slider:set_value(volume or s.volume_slider.value)
    --end)

    --gears.timer {
    --    autostart = true,
    --    callback  = function()
    --    get_volume(function(volume)
    --        s.volume_slider:set_value(volume or s.volume_slider.value)
    --    end)
    --end}

    s.widget_volume_slider = wibox.widget {
        {
            {
                {
                    s.volume_slider,
                    layout = wibox.layout.align.horizontal,
                },
                left   = 15,
                right  = 15,
                widget = wibox.container.margin,
            },
            bg     = beautiful.nord0,
            shape  = gears.shape.rounded_bar,
            widget = wibox.container.background,
        },
        strategy = 'exact',
        width    = width - 20,
        height   = 60,
        widget = wibox.container.constraint
    }

    local old_cursor, old_wibox
    s.volume_slider:connect_signal("mouse::enter", function(c)
        c:set_handle_color(beautiful.nord7)
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand1"
    end)
    s.volume_slider:connect_signal("mouse::leave", function(c)
        c:set_handle_color(beautiful.nord4)
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    --volume_slider:connect_signal("button::press", function(c)
    --    if button == 1 then
    --        c:set_handle_color(beautiful.nord6)
    --    end
    --end)
    s.volume_slider:connect_signal("button::press",   function(c) c:set_handle_color(beautiful.nord8) end)
    s.volume_slider:connect_signal("button::release", function(c) c:set_handle_color(beautiful.nord7) end)

    s.control_panel = awful.wibar {
        bg       = beautiful.control_panel_bg,
        position = 'right',
        stretch  = true,
        visible  = false,
        ontop    = true,
        screen   = s,
        width    = width,
        layout = wibox.layout.flex.vertical,
    }

    s.control_panel:setup {
        direction = "east",
        layout    = wibox.layout.align.vertical,
        --[[{
            s.widget_volume_icon,
            layout = wibox.layout.fixed.vertical,
        },
        {
            s.widget_volume_icon,
            layout = wibox.layout.flex.vertical,
        },--]]
        {
            {
                {
                    --[[{
                        s.widget_volume_icon,
                        layout = wibox.layout.fixed.horizontal,
                    },--]]
                    {
                        nil,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    {
                        s.widget_volume_slider,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    {
                        nil,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    bg     = beautiful.nord2,
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
            bg = beautiful.button_normal,
            shape_border_width = 1,
            shape_border_color = '#d8dee9',
            shape = gears.shape.rounded_bar,
            widget = wibox.container.background,
        },
        margins = 4,
        widget = wibox.container.margin,
    }

    if s.control_panel.visible == true then
        s.control_panel_button.widget.widget.widget.text = '▶'
    else
        s.control_panel_button.widget.widget.widget.text = '◀'
    end

    --local old_cursor, old_wibox
    --s.control_panel_button.widget:connect_signal("mouse::enter", function(c)
    --    c:set_bg(beautiful.button_enter) -- hovered  / nord 2
    --    local wb = mouse.current_wibox
    --    old_cursor, old_wibox = wb.cursor, wb
    --    wb.cursor = "hand1"
    --end)
    --s.control_panel_button.widget:connect_signal("mouse::leave", function(c)
    --    c:set_bg(beautiful.button_normal) -- default  / nord 1
    --    if old_wibox then
    --        old_wibox.cursor = old_cursor
    --        old_wibox = nil
    --    end
    --end)

    --s.control_panel_button.widget:connect_signal("button::press",   function(c) c:set_bg(beautiful.button_press) end) -- pressed  / nord 3
    buttonify({widget = s.control_panel_button.widget})
    s.control_panel_button.widget:connect_signal("button::release", function(c)
        --c:set_bg(beautiful.button_release) -- released / nord 2
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

--[[function control_panel_widget(s)
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
        bar_shape           = gears.shape.rounded_bar,
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
            shape  = gears.shape.rounded_bar,
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
            bg = beautiful.button_normal,
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
        c:set_bg(beautiful.button_enter)
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand1"
    end)
    s.control_panel_button.widget:connect_signal("mouse::leave", function(c)
        c:set_bg(beautiful.button_normal)
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    s.control_panel_button.widget:connect_signal("button::press",   function(c) c:set_bg(beautiful.button_press) end)
    s.control_panel_button.widget:connect_signal("button::release", function(c)
        c:set_bg(beautiful.button_release)
        if s.control_panel.visible == false then
            s.control_panel.visible = true
            s.control_panel_button.widget.widget.widget.text = '▶'
        else
            s.control_panel.visible = false
            s.control_panel_button.widget.widget.widget.text = '◀'
        end
    end)

    return(s.control_panel_button)
end --]]
