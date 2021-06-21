local username = os.getenv('USER')

--- VOLUME ---
--local get_volume_cmd = 'bash -c "while true; do pamixer --get-volume; sleep 0.1; done"'
awful.spawn.easy_async({'pkill', '--full', '--uid', username, '^bash -c while true; do pamixer --get-volume; sleep 0.1; done'}, function()
	awful.spawn.with_line_callback('bash -c "while true; do pamixer --get-volume; sleep 0.1; done"', {stdout = function(stdout)
		awesome.emit_signal('qrlinux::media::get_volume', tonumber(stdout))
	end})
end)

awesome.connect_signal('qrlinux::media::set_volume', function(volume)
	local v
	v = tonumber(volume)
	if volume < 0 then
		v = 0
	elseif volume > 100 then
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
--local get_mute_cmd = 'bash -c "while true; do pamixer --get-mute; sleep 0.1; done"'
--naughty.notify({ text = ('pkill --full --uid \'^' .. username ..' '.. get_mute_cmd .. '\'')})
--awful.spawn.easy_async_with_shell({'pkill', '--full', '--uid', username, get_mute_cmd}, function()
awful.spawn.easy_async({'pkill', '-fU', username, '^bash -c while true; do pamixer --get-mute; sleep 0.1; done'}, function()
	awful.spawn.with_line_callback('bash -c "while true; do pamixer --get-mute; sleep 0.1; done"', {stdout = function(stdout)
		awesome.emit_signal('qrlinux::media::get_mute', stdout)
	end})
end)

--gears.timer {
--	autostart = true,
--	callback  = function()
--		--naughty.notify({text = 'TEST'})
--	end
--}