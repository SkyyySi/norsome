local filesystem = require('gears.filesystem')
local with_dpi = require('beautiful').xresources.apply_dpi
local get_dpi = require('beautiful').xresources.get_dpi

local run_on_start_up = {
    'timidity -iA',
    'picom',
    'pasystray',
    'xscreensaver -no-splash',
    'unclutter -b',
    'blueman-applet 2>/dev/null',
    'lxsession --session=awesome --de=awesome',
    'ulauncher',
--  'bash /home/simon/.screenlayout/90_tripplescreen.sh',
--  'bash /home/simon/.config/start_jack.sh',
--  'gnome-flashback 2>/dev/null',
--  'glava -d >/dev/null'
}

local function run_once(cmd)
    local findme = cmd
    local firstspace = cmd:find(' ')
    if firstspace then
        findme = cmd:sub(0, firstspace - 1)
    end
    awful.spawn.with_shell(string.format('pgrep -u $USER -x %s > /dev/null || (%s)', findme, cmd))
end

for _, app in ipairs(run_on_start_up) do
    run_once(app)
end
