--------------------------
-- Nordic awesome theme --
--------------------------

local gfs          = require('gears.filesystem')
local theme_assets = require('beautiful.theme_assets')
local xresources   = require('beautiful.xresources')
local dpi          = xresources.apply_dpi
local themes_path  = gfs.get_themes_dir()

local theme = {}
-- The names are actually nord0, nord1, ..., nord15, but lua does
-- not allow for variable names to start with numbers. Thus, letters
-- are used here instead.
theme.nord0  = '#2E3440' -- Polar Night 1
theme.nord1  = '#3B4252' -- Polar Night 2
theme.nord2  = '#434C5E' -- Polar Night 3
theme.nord3  = '#4C566A' -- Polar Night 4
theme.nord4  = '#D8DEE9' -- Snow Storm 1
theme.nord5  = '#E5E9F0' -- Snow Storm 2
theme.nord6  = '#ECEFF4' -- Snow Storm 3
theme.nord7  = '#8FBCBB' -- Frost 1
theme.nord8  = '#88C0D0' -- Frost 2
theme.nord9  = '#81A1C1' -- Frost 3
theme.nord10 = '#5E81AC' -- Frost 4
theme.nord11 = '#BF616A' -- Aurora 1
theme.nord12 = '#D08770' -- Aurora 2
theme.nord13 = '#EBCB8B' -- Aurora 3
theme.nord14 = '#A3BE8C' -- Aurora 4
theme.nord15 = '#B48EAD' -- Aurora 5

theme.font           = 'Source Sans Pro 11'

theme.bg_normal      = theme.nord0
theme.bg_focus       = theme.nord10
theme.bg_urgent      = theme.nord12
theme.bg_minimize    = theme.nord1
theme.bg_systray     = theme.bg_normal

theme.fg_normal      = theme.nord4
theme.fg_focus       = theme.nord4
theme.fg_urgent      = theme.nord0
theme.fg_minimize    = theme.nord4

theme.useless_gap    = dpi(2)
theme.border_width   = dpi(2)
theme.border_normal  = theme.nord3
theme.border_focus   = theme.nord4
theme.border_marked  = theme.nord4

theme.button_normal  = theme.nord1        -- default
theme.button_enter   = theme.nord2        -- hovered
theme.button_press   = theme.nord3        -- pressed
theme.button_release = theme.button_enter -- released
theme.button_border_shape = gears.shape.rounded_bar
theme.button_border_color = theme.nord4 or '#FFFFFF'
theme.button_border_width = dpi(1)

theme.menubutton_normal  = '#00000000'             -- default
theme.menubutton_enter   = theme.button_enter      -- hovered
theme.menubutton_press   = theme.button_press      -- pressed
theme.menubutton_release = theme.button_enter      -- released
theme.menubutton_leave   = theme.menubutton_normal -- released

theme.bg_systray = theme.button_normal or theme.nord1

theme.taglist_bg_empty     = theme.nord1
theme.taglist_bg_occupied  = theme.nord2
theme.taglist_disable_icon = true
theme.taglist_font         = 'Source Code Pro black 16'
--theme.taglist_shape        = gears.shape.rounded_bar

theme.control_panel_bg = theme.nord1 .. 'D0'

theme.systray_icon_spacing = dpi(10)
theme.systray_icon_size    = dpi(15)

-- Titlebars
theme.titlebar_bg_normal = theme.nord1 or '#353C4A'
theme.titlebar_size      = dpi(28)
theme.titlebar_radius    = dpi(20)

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = '#ff0000'

-- Generate taglist squares:
local taglist_square_size = dpi(4)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
--theme.menu_submenu_icon = theme_dir .. 'submenu.png'
theme.menu_border_color = theme.fg_normal
theme.menu_height = dpi(30)
theme.menu_width  = dpi(175)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = '#cc0000'

-- Define the image to load
theme.titlebar_close_button_normal = theme_dir .. 'titlebar/close_normal.png'
theme.titlebar_close_button_focus  = theme_dir .. 'titlebar/close_focus.png'

theme.titlebar_minimize_button_normal = theme_dir .. 'titlebar/minimize_normal.png'
theme.titlebar_minimize_button_focus  = theme_dir .. 'titlebar/minimize_focus.png'

theme.titlebar_ontop_button_normal_inactive = theme_dir .. 'titlebar/ontop_normal_inactive.png'
theme.titlebar_ontop_button_focus_inactive  = theme_dir .. 'titlebar/ontop_focus_inactive.png'
theme.titlebar_ontop_button_normal_active   = theme_dir .. 'titlebar/ontop_normal_active.png'
theme.titlebar_ontop_button_focus_active    = theme_dir .. 'titlebar/ontop_focus_active.png'

theme.titlebar_sticky_button_normal_inactive = theme_dir .. 'titlebar/sticky_normal_inactive.png'
theme.titlebar_sticky_button_focus_inactive  = theme_dir .. 'titlebar/sticky_focus_inactive.png'
theme.titlebar_sticky_button_normal_active   = theme_dir .. 'titlebar/sticky_normal_active.png'
theme.titlebar_sticky_button_focus_active    = theme_dir .. 'titlebar/sticky_focus_active.png'

theme.titlebar_floating_button_normal_inactive = theme_dir .. 'titlebar/floating_normal_inactive.png'
theme.titlebar_floating_button_focus_inactive  = theme_dir .. 'titlebar/floating_focus_inactive.png'
theme.titlebar_floating_button_normal_active   = theme_dir .. 'titlebar/floating_normal_active.png'
theme.titlebar_floating_button_focus_active    = theme_dir .. 'titlebar/floating_focus_active.png'

theme.titlebar_maximized_button_normal_inactive = theme_dir .. 'titlebar/maximized_normal_inactive.png'
theme.titlebar_maximized_button_focus_inactive  = theme_dir .. 'titlebar/maximized_focus_inactive.png'
theme.titlebar_maximized_button_normal_active   = theme_dir .. 'titlebar/maximized_normal_active.png'
theme.titlebar_maximized_button_focus_active    = theme_dir .. 'titlebar/maximized_focus_active.png'

--theme.wallpaper = theme_dir .. 'background.png'

-- You can use your own layout icons like this:
theme.layout_fairh      = theme_dir .. 'layouts/fairhw.png'
theme.layout_fairv      = theme_dir .. 'layouts/fairvw.png'
theme.layout_floating   = theme_dir .. 'layouts/floatingw.png'
theme.layout_magnifier  = theme_dir .. 'layouts/magnifierw.png'
theme.layout_max        = theme_dir .. 'layouts/maxw.png'
theme.layout_fullscreen = theme_dir .. 'layouts/fullscreenw.png'
theme.layout_tilebottom = theme_dir .. 'layouts/tilebottomw.png'
theme.layout_tileleft   = theme_dir .. 'layouts/tileleftw.png'
theme.layout_tile       = theme_dir .. 'layouts/tilew.png'
theme.layout_tiletop    = theme_dir .. 'layouts/tiletopw.png'
theme.layout_spiral     = theme_dir .. 'layouts/spiralw.png'
theme.layout_dwindle    = theme_dir .. 'layouts/dwindlew.png'
theme.layout_cornernw   = theme_dir .. 'layouts/cornernww.png'
theme.layout_cornerne   = theme_dir .. 'layouts/cornernew.png'
theme.layout_cornersw   = theme_dir .. 'layouts/cornersww.png'
theme.layout_cornerse   = theme_dir .. 'layouts/cornersew.png'

-- Generate Awesome icon:
--[[theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)]]--

theme.icon = {}

--- ICONS ---
--theme.awesome_icon = theme_dir .. 'qrlinux/QRLinux-logo.svg' -- main logo
theme.awesome_icon  = theme_dir .. 'qrlinux/QRLinux-logo-nobg.svg' -- main logo
theme.icon.power    = theme_dir .. 'qrlinux/power-button.svg' -- power (off) button
theme.icon.app      = theme_dir .. 'qrlinux/generic-app.svg' -- symbol of a generic app
theme.icon.terminal = theme_dir .. 'qrlinux/terminal.svg'
theme.icon.folder   = theme_dir .. 'qrlinux/folder.svg'
theme.icon.web      = theme_dir .. 'qrlinux/web.svg'
theme.icon.note     = theme_dir .. 'qrlinux/musical-note.svg'

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return(theme)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
