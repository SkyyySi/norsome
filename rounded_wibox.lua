local rounded_rectangle = require("rounded_rectangle")

-- Create a wibox with smooth rounded corners
local rounded_wibox
function rounded_wibox(arg)
    local radius       = arg.radius       or dpi(10)
    local width        = arg.width        or dpi(200)
    local height       = arg.height       or dpi(200)
    local border_width = arg.border_width or dpi(1)
    local bg_color     = arg.bg_color     or '#202020'
    local border_color = arg.border_color or '#FFFFFF'
    local visible      = arg.visible      or true
    local ontop        = arg.ontop        or true

    local round_wibox = wibox {
        width              = width,
        height             = height,
        visible            = visible,
        ontop              = ontop,
        shape_border_width = border_width,
        shape_border_color = border_color,
        shape              = rounded_rectangle(radius),
        type               = 'normal',
        bg                 = '#0000',
    }

    local round_wibox_content = wibox.widget {
        align  = 'center',
        valign = 'center',
        text   = 'Hello world',
        widget = wibox.widget.textbox,
    }

    local widget = arg.widget or round_wibox_content

    radius = radius + dpi(2)
    round_wibox:setup {
        {
            widget,
            layout = wibox.layout.flex.horizontal,
        },
        bg                 = bg_color,
        shape_border_width = border_width,
        shape_border_color = border_color,
        shape  = rounded_rectangle(radius),
        widget = wibox.container.background,
    }

    return round_wibox
end

return rounded_wibox

-- Usage example:
-- -- What to show in the box
-- local rounded_wibox_content = wibox.widget {
--     font   = 'Source Sans Pro Bold 20',
--     align  = 'center',
--     valign = 'center',
--     text   = 'IT WORKS!!!',
--     widget = wibox.widget.textbox,
-- }
-- 
-- -- Create a new box
-- local round_box = rounded_wibox ({
--     widget   = rounded_wibox_content,
--     bg_color = '#303030',
--     radius   = dpi(20),
--     height   = dpi(100),
-- })
-- 
-- -- Place it on screen
-- awful.placement.top(round_box, { margins = {top = dpi(40)}, parent = awful.screen.focused()})