--- TAGLIST ---
local taglist
function taglist(s)
	s.taglist_buttons = gears.table.join(
		awful.button({ }, 1, function(t) t:view_only() end),
		awful.button({ modkey }, 1, function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end),
		awful.button({ }, 3, awful.tag.viewtoggle),
		awful.button({ modkey }, 3, function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end),
		awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
		awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end)
	)

    s.taglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = s.taglist_buttons,

        style  = {
            shape = gears.shape.rounded_bar,
        },

        layout = {
            spacing = dpi(4),
            layout  = wibox.layout.fixed.horizontal
        },

        widget_template = {
            {{{
                        id     = 'index_role',
                        font   = beautiful.taglist_font,
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                id     = 'background_role',
                widget = wibox.container.background,
            },
            --top    = 4,
            --bottom = 4,
            widget = wibox.container.margin,

            -- Add support for hover colors and an index label
            create_callback = function(self, c3, index, objects) --luacheck: no unused args
                local old_cursor, old_wibox
                self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
                self:connect_signal('mouse::enter', function()
		                local wb = mouse.current_wibox
		                old_cursor, old_wibox = wb.cursor, wb
		                wb.cursor = "hand1"
                    if self.bg ~= beautiful.nord8 then
                        self.backup     = self.bg
                        self.has_backup = true
                    end
                    self.bg = beautiful.nord8
                end)
                self:connect_signal('mouse::leave', function()
                    if old_wibox then
                        old_wibox.cursor = old_cursor
                        old_wibox = nil
                    end
                    if self.has_backup then self.bg = self.backup end
                end)
            end,
            update_callback = function(self, c3, index, objects) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
            end,
        },
    }

    s.taglist_widget = wibox.widget {
        {{{{
                        s.taglist,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    widget = wibox.container.margin,
                },
                bg                 = beautiful.taglist_bg_empty,
                shape              = gears.shape.rounded_bar,
                widget             = wibox.container.background,
                shape_border_width = 1,
                shape_border_color = beautiful.nord4,
            },
            margins = dpi(4),
            widget = wibox.container.margin,
        },
        layout = wibox.layout.fixed.horizontal,
    }

    return(s.taglist_widget)
end

return(taglist)