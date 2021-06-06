
-- Create an imagebox widget which will contain an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local current_wibox
function current_wibox(s)
    s.layoutbox = awful.widget.layoutbox(s)
    s.layoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)
    ))

    return(s.layoutbox)
end

return(current_wibox)