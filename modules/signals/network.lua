local username = os.getenv('USER')
local confdir  = awful.util.getdir('config')

local wifi_status_command = (confdir .. 'scripts/wifi_status.sh')
awful.spawn.easy_async_with_shell('pkill -fU ' .. username .. wifi_status_command, function()
	awful.spawn.with_line_callback((wifi_status_command), { stdout = function(status)
		local s

		if (status == 'enabled') then
			s = true
		elseif (status == 'disabled') then
			s = false
		end

		awesome.emit_signal('qrlinux::wifi::enabled', s)
	end })
end)

local wifi_toggle_command = [[nmcli -c no r wifi]]
awesome.connect_signal('qrlinux::wifi::toggle', function()
	awful.spawn.easy_async_with_shell(wifi_toggle_command, function(status)
		status = status:gsub('\n', '')
		local s

		if (status == 'enabled') then
			s = 'off'
		elseif (status == 'disabled') then
			s = 'on'
		end

		awful.spawn.with_shell(wifi_toggle_command .. ' ' .. s)
	end)
end)
