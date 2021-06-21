local rounded_rectangle = require('rounded_rectangle')
local infobubble        = require('infobubble')
local buttonify         = require('buttonify')

local volume_button
function volume_button(s)
    local s = s or awful.screen.focused()
    s.volume_widget = {}
    local arrow_width = dpi(10)
    s.volume_widget.shape = infobubble(dpi(20), arrow_width)

    -- Read the current pulse audio volume using the pamixer command
    function s.volume_widget.get_volume(f)
        awful.spawn.easy_async('pamixer --get-volume', function(vol)
            f(tonumber(vol))
        end)
    end

    -- How the widget should look in the wibox / panel
    s.volume_widget.volume_button_text = wibox.widget {
        font   = 'Source Code Pro Bold 12',
        text   = '🔊 50',
        widget = wibox.widget.textbox,
    }

    awesome.connect_signal('qrlinux::media::get_volume', function(volume)
        --naughty.notify({text = tostring(volume)})
        local text = volume
            if volume == 0 then text = '🔇 ' .. tostring(volume)
        elseif volume < 25 then text = '🔈 ' .. tostring(volume)
        elseif volume < 75 then text = '🔉 ' .. tostring(volume)
        else                    text = '🔊 ' .. tostring(volume)
        end
        s.volume_widget.volume_button_text:set_text(text)
    end)

    -- The widget to show in the wibox / panel
    s.volume_widget.volume_button = wibox.widget {
        {{{
                    s.volume_widget.volume_button_text,
                    layout  = wibox.layout.align.horizontal,
                },
                top = dpi(4), bottom = dpi(4), left = dpi(8), right = dpi(8),
                widget = wibox.container.margin
            },
            bg = beautiful.button_normal,
            shape_border_width = dpi(1),
            shape_border_color = beautiful.nord4 or '#d8dee9',
            shape = gears.shape.rounded_bar,
            widget = wibox.container.background,
        },
        margins = dpi(4),
        widget = wibox.container.margin
    }

    s.volume_widget.get_volume(function(volume)
        s.volume_widget.volslider = wibox.widget {
            bar_color           = beautiful.nord8 or '#88C0D0',
            bar_shape           = gears.shape.rounded_rect,
            bar_height          = dpi(2),
            handle_color        = beautiful.nord4 or '#D8DEE9',
            handle_border_color = beautiful.nord3 or '#4C566A',
            handle_border_width = dpi(2),
            handle_shape        = gears.shape.circle,
            handle_width        = dpi(25),

            value               = volume,
            minimum             = 0,
            maximum             = 100,

            forced_width        = dpi(200),
            forced_height       = dpi(50),

            widget              = wibox.widget.slider,
        }

        s.volume_widget.voltext = wibox.widget {
            font   = 'Source Sans Pro 16',
            text   = volume,
            widget = wibox.widget.textbox,
        }

        s.volume_widget.volume_slider = wibox.widget {
            {
                {
                    {
                        s.volume_widget.voltext,
                        layout = wibox.layout.align.horizontal,
                    },
                    margins = dpi(4),
                    widget = wibox.container.margin
                },
                {
                    {
                        s.volume_widget.volslider,
                        layout = wibox.layout.align.horizontal,
                    },
                    top = dpi(4), bottom = dpi(4), right = dpi(8),
                    widget = wibox.container.margin
                },
                layout  = wibox.layout.align.horizontal,
            },
            visible = true,
            widget  = wibox.container.background,
        }

        function s.volume_widget.update_volume(v)
            if v then
                --set_volume(v)
                if     v < 0   then v = 0
                elseif v > 100 then v = 100 end
                awesome.emit_signal('qrlinux::media::set_volume', v)
                volume = v
                s.volume_widget.volslider.value = v
            end
            s.volume_widget.voltext.text = volume
        end

        s.volume_widget.volslider:connect_signal('property::value', function()
            s.volume_widget.update_volume(s.volume_widget.volslider.value)
        end)

        local old_cursor, old_wibox
        s.volume_widget.volume_slider:connect_signal("mouse::enter", function(c)
            local wb = mouse.current_wibox
            old_cursor, old_wibox = wb.cursor, wb
            wb.cursor = "hand1"
        end)
        s.volume_widget.volume_slider:connect_signal("mouse::leave", function(c)
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end)

        s.volume_widget.volslider:connect_signal('mouse::enter',    function(c) c.handle_color = beautiful.nord7 or '#8FBCBB' end)
        s.volume_widget.volslider:connect_signal('mouse::leave',    function(c) c.handle_color = beautiful.nord4 or '#D8DEE9' end)
        s.volume_widget.volslider:connect_signal('button::press',   function(c) c.handle_color = beautiful.nord8 or '#88C0D0' end)
        s.volume_widget.volslider:connect_signal('button::release', function(c) c.handle_color = beautiful.nord7 or '#8FBCBB' end)

        --- ANTI-ALIASING ---

        -- Create the box
        s.volume_widget.volume_box_aa = wibox {
            ontop     = true,
            type      = 'dialog',
            placement = awful.placement.centered,
            height    = dpi(50) + arrow_width,
            width     = dpi(300),
            shape     = s.volume_widget.shape,
            visible   = false,
        }

        -- Place it at the center of the screen
        --awful.placement.centered(s.volume_box_aa)

        -- Set bg and fg
        s.volume_widget.volume_box_aa.bg = beautiful.nord0 .. '80' or '#2E344080'
        s.volume_widget.volume_box_aa.fg = beautiful.nord4         or '#D8DEE9'

        local volume_box_content = {
                {
                    font   = 'Source Sans Pro Bold 16',
                    text   = '    VOL: ',
                    widget = wibox.widget.textbox,
                },
                {
                    s.volume_widget.volume_slider,
                    layout = wibox.layout.align.horizontal,
                },
                margins   = dpi(32),
                layout    = wibox.layout.align.horizontal,
                widget    = wibox.container.margin,
        }

        -- Put its items in a shaped container
        s.volume_widget.volume_box_aa:setup {
            {
                {
                    {
                        volume_box_content,
                        layout = wibox.layout.align.horizontal
                    },
                    halign    = 'center',
                    valign    = 'center',
                    layout    = wibox.layout.align.horizontal,
                    placement = awful.placement.centered,
                    widget    = wibox.container.place,
                },
                top    = arrow_width,
                widget = wibox.container.margin,
            },
            shape_border_width = dpi(2),
            shape_border_color = '#FFFFFF',
            shape              = s.volume_widget.shape,
            widget             = wibox.widget.background,
        }

        s.volume_widget.volume_button:connect_signal("button::release", function(c, _, _, button)
            if button == 1 then
                s.volume_widget.update_volume()
                s.volume_widget.volume_box_aa.visible = not s.volume_widget.volume_box_aa.visible

                center = mouse.current_widget_geometry.x - (s.volume_widget.volume_box_aa.width / 2 or 0)
                awful.placement.top_left(s.volume_widget.volume_box_aa, { margins = {top = dpi(48), left = center }, parent = s })
            elseif button == 2 then
                awful.spawn('pavucontrol-qt')
            end
        end)

        s.volume_widget.volume_button:connect_signal("button::press", function(_, _, _, button)
            awful.spawn.easy_async('pamixer --get-volume', function(v)
                local v = tonumber(v)
                if button     == 4 then
                    v = v + 5 -- increase volume by 5 percent
                elseif button == 5 then
                    v = v - 5 -- decrease volume by 5 percent
                end
                s.volume_widget.update_volume(v)
            end)
        end)

        --awful.placement.top_right(s.volume_box_aa, { margins = {top = 48, right = 16}, parent = s})
        return(s.volume_widget.volume_button)
    end)

    buttonify({widget = s.volume_widget.volume_button.widget})

    return(s.volume_widget.volume_button)
end

return(volume_button)