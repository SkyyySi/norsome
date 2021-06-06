--- TASKLIST ---
local tasklist
function tasklist(s)
    s.tasklist_buttons = gears.table.join(
        awful.button({ }, 1, function (c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal(
                    "request::activate",
                    "tasklist",
                    {raise = true}
                )
            end
        end),

        awful.button({ }, 3, function()
            awful.menu.client_list({ theme = { width = 250 } })
        end),

        awful.button({ }, 4, function ()
            awful.client.focus.byidx(1)
        end),

        awful.button({ }, 5, function ()
            awful.client.focus.byidx(-1)
        end)
    )

    s.tasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style   = {
            shape              = gears.shape.rounded_bar,
            shape_border_width = 1,
            shape_border_color = beautiful.nord4,
        },
        layout  = {
            layout  = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    {
                        {
                            id     = 'clienticon',
                            widget = awful.widget.clienticon,
                        },
                        left   = 10,
                        right  = 10,
                        top    = 4,
                        bottom = 4,
                        widget = wibox.container.margin,
                    },
                    id     = 'background_role',
                    widget = wibox.container.background,
                },
                margins = 4,
                widget  = wibox.container.margin,
            },
            nil,
            create_callback = function(self, c, index, objects) --luacheck: no unused args
                self:get_children_by_id('clienticon')[1].client = c
                local old_cursor, old_wibox
                self:connect_signal("mouse::enter", function(c)
                    local wb = mouse.current_wibox
                    old_cursor, old_wibox = wb.cursor, wb
                    wb.cursor = "hand1"
                end)
                self:connect_signal("mouse::leave", function(c)
                    if old_wibox then
                        old_wibox.cursor = old_cursor
                        old_wibox = nil
                    end
                end)
            end,
            layout = wibox.layout.align.vertical,
        },
    }

    return(s.tasklist)
end

return(tasklist)