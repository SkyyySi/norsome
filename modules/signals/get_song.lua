local username = os.getenv('USER')

awful.spawn.easy_async({'pkill', '--full', '--uid', username, '^' .. awful.util.getdir('config') .. 'scripts/get_song_title.sh -t -f'}, function()
	awful.spawn.with_line_callback(awful.util.getdir('config') .. 'scripts/get_song_title.sh -t -f', {stdout = function(title)
		awesome.emit_signal('qrlinux::media::get_song_title', title)
	end})
end)

awful.spawn.easy_async({'pkill', '--full', '--uid', username, '^' .. awful.util.getdir('config') .. 'scripts/get_song_title.sh -a -f'}, function()
	awful.spawn.with_line_callback(awful.util.getdir('config') .. 'scripts/get_song_title.sh -a -f', {stdout = function(artist)
		awesome.emit_signal('qrlinux::media::get_song_artist', artist)
	end})
end)

awful.spawn.easy_async({'pkill', '--full', '--uid', username, '^' .. awful.util.getdir('config') .. 'scripts/get_song_title.sh -c -f'}, function()
	awful.spawn.with_line_callback(awful.util.getdir('config') .. 'scripts/get_song_title.sh -c -f', {stdout = function(cover)
		awesome.emit_signal('qrlinux::media::get_song_cover', cover)
	end})
end)

awful.spawn.easy_async({'pkill', '--full', '--uid', username, '^playerctl status -F'}, function()
	awful.spawn.with_line_callback('playerctl status -F', {stdout = function(s)
		local status = false
		if s == 'Playing' then
			status = true
		end
		awesome.emit_signal('qrlinux::media::get_song_status', status)
	end})
end)

--awesome.connect_signal('qrlinux::media::get_song_title', function(song)
--	awesome.connect_signal('qrlinux::media::get_song_artist', function(artist)
--		naughty.notify({text = 'Now playing: "' .. tostring(song) .. '" by ' .. tostring(artist)})
--	end)
--end)

--awful.spawn.easy_async({'pkill', '--full', '--uid', username, '^bash -c while true; do pamixer --get-volume; done'}, function()
--	awful.spawn.with_line_callback(get_volume_cmd, {stdout = function(out)
--			awesome.emit_signal('qrlinux::media::get_volume', tonumber(out))
--		end
--	})
--end)

local get_artist_cmd
function get_artist(f)
	awful.spawn.easy_async_with_shell(awful.util.getdir('config') .. '/scripts/get_song_title.sh -a', function(artist)
		f(artist)
	end)
end

local get_cover_cmd
function get_cover(f)
	awful.spawn.easy_async_with_shell(awful.util.getdir('config') .. '/scripts/get_song_title.sh -c', function(img)
		f(img)
	end)
end

local get_status_cmd
function get_status(f)
	awful.spawn.easy_async_with_shell('playerctl status', function(status)
		f(status)
		--naughty.notify({text = 'Status: ' .. status})
	end)
end
