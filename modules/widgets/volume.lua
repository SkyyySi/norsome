local rounded_rectangle = require('rounded_rectangle')

-- Read the current pulse audio volume using the pamixer command
function get_volume(f)
    awful.spawn.easy_async_with_shell('pamixer --get-volume', function(vol)
        f(tonumber(vol))
    end)
end

-- How the widget should look in the wibox / panel
local volume_button_text = wibox.widget {
    font   = 'MesloLFS Bold 12',
    text   = '🔊 ',
    widget = wibox.widget.textbox,
}

-- The widget to show in the wibox / panel
local volume_button = wibox.widget {
    {{{
                volume_button_text,
                layout  = wibox.layout.align.horizontal,
            },
            top = 4, bottom = 4, left = 8, right = 8,
            widget = wibox.container.margin
        },
        bg = '#4C566A',
        shape_border_width = 1,
        shape_border_color = '#d8dee9',
        shape = rounded_rectangle(20),
        widget = wibox.container.background,
    },
    margins = 4,
    widget = wibox.container.margin
}

function volume_button_update(v)
        if v == 0 then volume_button_text.text = '🔇 '
    elseif v < 25 then volume_button_text.text = '🔈 '
    elseif v < 75 then volume_button_text.text = '🔉 '
    else               volume_button_text.text = '🔊 '
    end
end

local volume_box_aa

get_volume(function(volume)
    volume_button_update(volume)

    local volslider = wibox.widget {
        bar_color           = '#CCCCCC',
        bar_shape           = gears.shape.rounded_rect,
        bar_height          = 2,
        handle_color        = '#999999',
        handle_border_color = '#FFFFFF',
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

    local voltext = wibox.widget {
        font   = 'Source Sans Pro 16',
        text   = volume,
        widget = wibox.widget.textbox,
    }

    local volume_slider = wibox.widget {
        {
            {
                {
                    voltext,
                    layout = wibox.layout.align.horizontal,
                },
                margins = 4,
                widget = wibox.container.margin
            },
            {
                {
                    volslider,
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

    function update_volume(v)
        if v then
            local vol
            if v < 0 then
                vol = 0
            elseif v > 100 then
                vol = 100
            else
                vol = v
            end
            awful.spawn('pamixer --set-volume '..vol)
            volume = vol
            volslider.value = vol
        end
        voltext.text = volume
        volume_button_update(volume)
    end

    volslider:connect_signal('property::value', function ()
        update_volume(volslider.value)
    end)

    local old_cursor, old_wibox
    volume_slider:connect_signal("mouse::enter", function(c)
        volume_slider.widget.handle_color = '#FFFFFF'
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand1"
    end)
    volume_slider:connect_signal("mouse::leave", function(c)
        volume_slider.widget.handle_color = '#999999'
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    volslider:connect_signal("mouse::enter", function(c)
        c.handle_color = '#DDDDDD'
    end)
    volslider:connect_signal("mouse::leave", function(c)
        c.handle_color = '#999999'
    end)

    --- ANTI-ALIASING ---

    -- Create the box
    volume_box_aa = wibox({
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
    awful.placement.centered(volume_box_aa)

    -- Set bg and fg
    volume_box_aa.bg = "#2e344080"
    volume_box_aa.fg = "#d8dee9"

    local volume_box_content = {
            {
                font   = 'Source Sans Pro Bold 16',
                text   = '    VOL: ',
                widget = wibox.widget.textbox,
            },
            {
                volume_slider,
                layout = wibox.layout.align.horizontal,
            },
            margins   = 32,
            layout    = wibox.layout.align.horizontal,
            widget    = wibox.container.margin,
    }

    -- Put its items in a shaped container
    volume_box_aa:setup {
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

    volume_button:connect_signal("button::release", function(c, _, _, button)
        if button == 1 then
            update_volume()
            volume_box_aa.visible = not volume_box_aa.visible
        elseif button == 2 then
            awful.spawn('pavucontrol')
        end
    end)

    volume_button:connect_signal("button::press", function(c, _, _, button)
        local vol
        if button     == 4 then
            vol = volume + 5 -- increase volume by 5 percent
        elseif button == 5 then
            vol = volume - 5 -- decrease volume by 5 percent
        end
        update_volume(vol)
    end)

    awful.placement.top_right(volume_box_aa, { margins = {top = 48, right = 16}, parent = awful.screen.focused()})
	return(volume_button)
end)

client.connect_signal("mouse::enter", function(c)
    if volume_box_aa.visible == false then
        awful.placement.top_right(volume_box_aa, { margins = {top = 48, right = 16}, parent = awful.screen.focused()})
    end
end)

return(volume_button)