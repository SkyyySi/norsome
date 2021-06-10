local username = os.getenv('USER')

--- VOLUME ---
local get_volume_cmd = 'bash -c "while true; do pamixer --get-volume; sleep 0.1; done"'
awful.spawn.easy_async({'pkill', '--full', '--uid', username, "^'" .. get_volume_cmd .. '"'}, function()
	awful.spawn.with_line_callback(get_volume_cmd, {stdout = function(out)
		awesome.emit_signal('qrlinux::media::get_volume', tonumber(out))
	end})
end)

awesome.connect_signal('qrlinux::media::set_volume', function(_volume)
	local v
	v = tonumber(_volume)
	if _volume < 0 then
		v = 0
	elseif _volume > 100 then
		v = 100
	end

	awful.spawn('pamixer --set-volume ' .. v)
end)

--[[ function set_volume(volume)
	local v = tonumber(volume)
	if volume < 0 then
		v = 0
	elseif volume > 100 then
		v = 100
	end

	awful.spawn('pamixer --set-volume ' .. v)
end --]]

--- MUTE ---
local get_mute_cmd = 'bash -c "while true; do pamixer --get-mute; sleep 0.1; done"'
awful.spawn.easy_async({'pkill', '--full', '--uid', username, "^'" .. get_mute_cmd .. '"'}, function()
	awful.spawn.with_line_callback(get_mute_cmd, {stdout = function(out)
			awesome.emit_signal('qrlinux::media::get_mute', out)
		end
	})
end)

--gears.timer {
--	autostart = true,
--	callback  = function()
--		--naughty.notify({text = 'TEST'})
--	end
--}