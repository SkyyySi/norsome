-- A small helper module that adds hover and click effects
-- to a widget, to make it "feel" more like a button.

local buttonify
function buttonify(args)
	local widget         = args.widget         or nil
	local button_enter   = args.button_enter   or beautiful.button_enter
	local button_normal  = args.button_normal  or beautiful.button_normal
	local button_press   = args.button_press   or beautiful.button_press
	local button_release = args.button_release or beautiful.button_release

	local old_cursor, old_wibox
	widget:connect_signal("mouse::enter", function(c)
		c:set_bg(button_enter) -- hovered  / nord 2
		local wb = mouse.current_wibox
		old_cursor, old_wibox = wb.cursor, wb
		wb.cursor = "hand1"
	end)
	widget:connect_signal("mouse::leave", function(c)
		c:set_bg(button_normal) -- default  / nord 1
		if old_wibox then
			old_wibox.cursor = old_cursor
			old_wibox = nil
		end
	end)
	widget:connect_signal("button::press",   function(c) c:set_bg(button_press)   end) -- pressed  / nord 3
	widget:connect_signal("button::release", function(c) c:set_bg(button_release) end) -- released / nord 2
end

return(buttonify)