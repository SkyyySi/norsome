-- Tip: pass `screen.primary` as the argument, that way it'll always
-- be placed on... well, your primary screen :)
--- SYSTEM TRAY ---
systray_placed  = false
local systray
function systray(s)
    s.systray_widget = wibox.widget{
        {{{{
                        reverse        = false,
                        set_horizontal = true,
                        set_base_size  = 22,
                        forced_height  = 20,
                        widget         = wibox.widget.systray,
                    },
                    left = 20, right = 20, top = 3,
                    widget = wibox.container.margin,
                },
                layout = wibox.layout.flex.horizontal,
            },
            bg                 = beautiful.bg_systray,
            shape_border_color = '#d8dee9',
            shape_border_width = 1,
            shape              = gears.shape.rounded_bar,
            widget             = wibox.container.background,
        },
        margins = 4,
        widget  = wibox.container.margin,
    }

	-- You can't have multiple systrays
    if not systray_placed then
        systray_placed = true
        return(s.systray_widget)
    else
        return(nil)
    end
end

return(systray)