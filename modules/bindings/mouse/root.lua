-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () awesome_menu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev), -- up
    awful.button({ }, 5, awful.tag.viewnext)  -- down
))
-- }}}
