local rounded_rectangle = require('rounded_rectangle')
local buttonify         = require('buttonify')

local s = s or awful.screen.focused()
function s.volume_button(s)
    -- Read the current pulse audio volume using the pamixer command
    function s.get_volume(f)
        awful.spawn.easy_async_with_shell('pamixer --get-volume', function(vol)
            f(tonumber(vol))
        end)
    end

    -- How the widget should look in the wibox / panel
    s.volume_button_text = wibox.widget {
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
        s.volume_button_text:set_text(text)
    end)

    -- The widget to show in the wibox / panel
    s.volume_button = wibox.widget {
        {{{
                    s.volume_button_text,
                    layout  = wibox.layout.align.horizontal,
                },
                top = 4, bottom = 4, left = 8, right = 8,
                widget = wibox.container.margin
            },
            bg = beautiful.button_normal,
            shape_border_width = 1,
            shape_border_color = beautiful.nord4 or '#d8dee9',
            shape = gears.shape.rounded_bar,
            widget = wibox.container.background,
        },
        margins = 4,
        widget = wibox.container.margin
    }

    s.get_volume(function(volume)
        s.volslider = wibox.widget {
            bar_color           = beautiful.nord8 or '#88C0D0',
            bar_shape           = gears.shape.rounded_rect,
            bar_height          = 2,
            handle_color        = beautiful.nord4 or '#D8DEE9',
            handle_border_color = beautiful.nord3 or '#4C566A',
            handle_border_width = 2,
            handle_shape        = gears.shape.circle,
            handle_width        = 25,

            value               = volume,
            minimum             = 0,
            maximum             = 100,

            forced_width        = 200,
            forced_height       = 50,

            widget              = wibox.widget.slider,
        }

        s.voltext = wibox.widget {
            font   = 'Source Sans Pro 16',
            text   = volume,
            widget = wibox.widget.textbox,
        }

        s.volume_slider = wibox.widget {
            {
                {
                    {
                        s.voltext,
                        layout = wibox.layout.align.horizontal,
                    },
                    margins = 4,
                    widget = wibox.container.margin
                },
                {
                    {
                        s.volslider,
                        layout = wibox.layout.align.horizontal,
                    },
                    top = 4, bottom = 4, right = 8,
                    widget = wibox.container.margin
                },
                layout  = wibox.layout.align.horizontal,
            },
            visible = true,
            widget  = wibox.container.background,
        }

        function s.update_volume(v)
            if v then
                set_volume(v)
                if     v < 0   then v = 0
                elseif v > 100 then v = 100 end
                awesome.emit_signal('qrlinux::media::set_volume', v)
                volume = v
                s.volslider.value = v
            end
            s.voltext.text = volume
        end

        s.volslider:connect_signal('property::value', function ()
            s.update_volume(s.volslider.value)
        end)

        local old_cursor, old_wibox
        s.volume_slider:connect_signal("mouse::enter", function(c)
            local wb = mouse.current_wibox
            old_cursor, old_wibox = wb.cursor, wb
            wb.cursor = "hand1"
        end)
        s.volume_slider:connect_signal("mouse::leave", function(c)
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end)

        s.volslider:connect_signal("mouse::enter", function(c)
            c.handle_color = beautiful.nord7 or '#8FBCBB'
        end)
        s.volslider:connect_signal("mouse::leave", function(c)
            c.handle_color = beautiful.nord4 or '#D8DEE9'
        end)
        s.volslider:connect_signal("button::press", function(c)
            c.handle_color = beautiful.nord8 or '#88C0D0'
        end)
        s.volslider:connect_signal("button::release", function(c)
            c.handle_color = beautiful.nord7 or '#8FBCBB'
        end)

        --- ANTI-ALIASING ---

        -- Create the box
        s.volume_box_aa = wibox({
            ontop   = true,
            type    = "dialog",
        --    x       = 690,
        --    y       = 1060,
            shape = function(cr,w,h)
                gears.shape.rounded_rect(cr,w,h,20)
            end;
            placement = awful.placement.centered,
            height    = 50,
            width     = 300,
            visible   = false,
        })

        -- Place it at the center of the screen
        awful.placement.centered(s.volume_box_aa)

        -- Set bg and fg
        s.volume_box_aa.bg = '#2e344080'
        s.volume_box_aa.fg = '#d8dee9'

        local volume_box_content = {
                {
                    font   = 'Source Sans Pro Bold 16',
                    text   = '    VOL: ',
                    widget = wibox.widget.textbox,
                },
                {
                    s.volume_slider,
                    layout = wibox.layout.align.horizontal,
                },
                margins   = 32,
                layout    = wibox.layout.align.horizontal,
                widget    = wibox.container.margin,
        }

        -- Put its items in a shaped container
        s.volume_box_aa:setup {
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
            shape_border_width = 2,
            shape_border_color = '#FFFFFF',
            shape  = rounded_rectangle(20),
            widget = wibox.widget.background,
        }

        s.volume_button:connect_signal("button::release", function(c, _, _, button)
            if button == 1 then
                s.update_volume()
                s.volume_box_aa.visible = not s.volume_box_aa.visible
            elseif button == 2 then
                awful.spawn('pavucontrol')
            end
        end)

        s.volume_button:connect_signal("button::press", function(c, _, _, button)
            local vol
            if button     == 4 then
                vol = volume + 5 -- increase volume by 5 percent
            elseif button == 5 then
                vol = volume - 5 -- decrease volume by 5 percent
            end
            s.update_volume(vol)
        end)

        awful.placement.top_right(s.volume_box_aa, { margins = {top = 48, right = 16}, parent = s})
        return(s.volume_button)
    end)

    buttonify({widget = s.volume_button.widget})

    return(s.volume_button)
end

return(s.volume_button)