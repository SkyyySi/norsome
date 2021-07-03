local rounded_rectangle = require('rounded_rectangle')
local infobubble        = require('infobubble')
local buttonify         = require('buttonify')

local music_button
function music_button(s)
    s.arrow_width = dpi(10)
	s.shape_size = dpi(20)
    s.shape = infobubble(s.shape_size, s.arrow_width)
	--[[
	local get_song
    function get_song(f)
        awful.spawn.easy_async_with_shell(awful.util.getdir('config') .. '/scripts/get_song_title.sh -t', function(song)
            f(song)
        end)
    end

	local get_artist
    function get_artist(f)
        awful.spawn.easy_async_with_shell(awful.util.getdir('config') .. '/scripts/get_song_title.sh -a', function(artist)
            f(artist)
        end)
    end

	local get_cover
	function get_cover(f)
		awful.spawn.easy_async_with_shell(awful.util.getdir('config') .. '/scripts/get_song_title.sh -c', function(img)
			f(img)
		end)
	end

	local get_status
	function get_status(f)
		awful.spawn.easy_async_with_shell('playerctl status', function(status)
			f(status)
			--naughty.notify({text = 'Status: ' .. status})
		end)
	end
	--]]

	-- The text on the button is a seperate widget so it's easier
	-- to change using a signal
	s.music_button_text = wibox.widget {
		text   = 'No song',
		widget = wibox.widget.textbox,
	}

	-- The button widget to put in the wibar
	s.music_button = wibox.widget {
		{
			{
				{
					s.music_button_text,
					layout = wibox.layout.align.horizontal,
				},
				left   = dpi(8),
				right  = dpi(8),
				widget = wibox.container.margin,
			},
			bg                 = beautiful.button_normal,
			shape              = gears.shape.rounded_bar,
			shape_border_width = dpi(1),
			shape_border_color = beautiful.nord4,
			widget             = wibox.container.background,
		},
		margins = dpi(4),
		widget  = wibox.container.margin,
		visible = true,
	}

	-- Hover effects
	buttonify({widget = s.music_button.widget})

	function s.print_status_sym(stat)
		local sym
		local playing = '⏸'
		local paused  = '⏵'

		if     stat == true  then sym = playing
		elseif stat == false then sym = paused
		else sym = ''
		end

		return(sym)
	end

	function s.set_song_title_icon(i) s.song_title_icon = i end
	function s.set_song_title_text(t) s.song_title_text = t end

	s.box = wibox {
		screen  = s,
		bg      = beautiful.nord0 .. '80' or '#2E344080',
		type    = 'dialog',
		ontop   = true,
		visible = false,
		width   = dpi(300),
		height  = dpi(180),
		shape   = s.shape
	}

	function s.box_content_makebutton(w, a)
		local button = wibox.widget {
			{
				{
					w,
					layout = wibox.layout.fixed.horizontal
				},
				margins = dpi(6),
				widget = wibox.container.margin,
			},
			bg                 = beautiful.nord1 or '#00000000',
			shape              = gears.shape.circle,
			shape_border_width = dpi(1),
			shape_border_color = (beautiful.nord4 or '#D8DEE9'),
			widget             = wibox.container.background
		}

		buttonify({widget = button})
		button:connect_signal('button::release', function()
			local action = load(a)
			action()
		end)

		return(button)
	end

	function s.music_control_widget(g, t)
		local gradient_width = g or dpi(250)
		local text_width     = t or (gradient_width - dpi(100))

		local box_content_button_playpause_text = wibox.widget {
			font   = 'Source Code Pro Bold 18',
			text   = '⏸',
			widget = wibox.widget.textbox,
		}
		local box_content_button_playpause = s.box_content_makebutton(box_content_button_playpause_text, "awful.spawn('playerctl play-pause')")

		local box_content_button_prev_text = wibox.widget {
			font   = 'Source Code Pro Bold 14',
			text   = '⏪',
			widget = wibox.widget.textbox,
		}
		local box_content_button_prev = s.box_content_makebutton(box_content_button_prev_text, "awful.spawn('playerctl previous')")

		local box_content_button_next_text = wibox.widget {
			font   = 'Source Code Pro Bold 14',
			text   = '⏩',
			widget = wibox.widget.textbox,
		}
		local box_content_button_next = s.box_content_makebutton(box_content_button_next_text, "awful.spawn('playerctl next')")

		local box_content_text_title = wibox.widget {
			align  = 'left',
			font   = 'Source Code Sans Bold 14',
			text   = 'No song',
			widget = wibox.widget.textbox,
		}

		awesome.connect_signal('qrlinux::media::get_song_title', function(t)
			box_content_text_title:set_text(t)
		end)

		local box_content_text_artist = wibox.widget {
			align  = 'right',
			text   = 'No artist',
			widget = wibox.widget.textbox,
		}

		local content_progessbar = wibox.widget {
			min_value        = 0,
			max_value        = 100,
			value            = 50,
			background_color = (beautiful.nord1 .. '80') or '#3B425280',
			--color            = beautiful.nord9 or '#81A1C1',
			color = gears.color {
				type  = 'linear',
				from  = { 0, 0 },
				to    = { gradient_width, 0 },
				stops = { { 0, beautiful.nord11 }, { 0.5, beautiful.nord12 }, { 1, beautiful.nord13 } }
			},
			border_width     = dpi(1),
			border_color     = beautiful.nord4,
			shape            = gears.shape.rounded_bar,
			bar_shape        = gears.shape.rounded_bar,
			widget           = wibox.widget.progressbar
		}

		gears.timer {
			autostart = true,
			timeout   = 0.1,
			callback  = function()
				awful.spawn.easy_async({'playerctl', 'metadata', 'mpris:length'}, function(value)
					local v = 100
					v = string.gsub(value, '\n', '')
					v = tonumber(value)
					content_progessbar:set_max_value(v or 100)
				end)
				awful.spawn.easy_async_with_shell('playerctl metadata --format "{{ position }}"', function(value)
					local v = 0
					v = string.gsub(value, '\n', '')
					v = tonumber(value)
					content_progessbar:set_value(v or 0)
				end)
			end
		}

		local content_progessbar_container = wibox.widget {
			{
				content_progessbar,
				layout = wibox.layout.fixed.horizontal
			},
			margins = dpi(8),
			widget  = wibox.container.margin
		}

		local box_content_coverart = wibox.widget {
			{
				resize = true,
				image  = (beautiful.icon.note or beautiful.awesome_icon),
				widget = wibox.widget.imagebox,
			},
			shape  = rounded_rectangle(s.shape_size / 4),
			widget = wibox.container.background,
		}

		local cover_art_path = ''
		function set_cover_art_path(path)
			cover_art_path = tostring(path)
		end

		--local cover_art_checksum = ''
		--local function set_cover_art_checksum(checksum)
		--	cover_art_checksum = tostring(checksum)
		--end

		--awesome.connect_signal('qrlinux::media::get_song_cover', function(i)
		awesome.connect_signal('bling::playerctl::title_artist_album', function(_, _, i, _)
			local time = os.time(os.date("!*t")) -- This has to be done because the file path will always be the same
			local username = os.getenv('USER')
			local filepath = ('/tmp/awesome_' .. username .. '/')
			awful.spawn.with_shell('mkdir "/tmp/awesome_"' .. username)
			local filename = (filepath .. 'media_cover_' .. time .. '.jpg')
			--if not s.cover_art_path == filename then
			--	awful.spawn({'rm', '-f', s.cover_art_path})
			--end

			box_content_coverart.widget:set_image(beautiful.icon.note or beautiful.awesome_icon)
			awful.spawn.with_shell('rm -f ' .. filepath .. '*.jpg')
			awful.spawn.easy_async_with_shell('ffmpeg -i ' .. i .. [[ -vf "crop=w='min(min(iw\,ih)\,500)':h='min(min(iw\,ih)\,500)',scale=500:500,setsar=1" -vframes 1 ]] .. filename .. ' > /dev/null; echo now', function()
				local p = filename
				set_cover_art_path(p)
				box_content_coverart.widget:set_image(p)
			end)
		end)

		gears.timer {
			autostart = true,
			timeout   = 1,
			callback  = function()
				box_content_coverart.widget:set_image(cover_art_path)
			end
		}

		awesome.connect_signal('qrlinux::media::get_song_artist', function(a)
			if (not a) or a == '' then a = 'No artist' end
			box_content_text_artist:set_text(a)
		end)

		local box_content_container = wibox.widget {
			{
				{
					{
						{
							{
								{
									box_content_coverart,
									layout = wibox.layout.fixed.horizontal,
								},
								bg                 = '#00000040',
								--shape              = function(cr) gears.shape.rounded_rect(cr, dpi(82), dpi(82), (s.shape_size / 4)) end,
								shape              = rounded_rectangle(s.shape_size / 4),
								shape_clip         = true,
								shape_border_width = dpi(1),
								shape_border_color = (beautiful.nord3 or '#4C566A'),
								widget             = wibox.container.background,
							},
							strategy = 'exact',
							width    = dpi(82),
							widget   = wibox.container.constraint,
						},
						margins = dpi(8),
						widget  = wibox.container.margin,
					},
					{
						wibox.widget {
							box_content_text_title,
							layout        = wibox.container.scroll.horizontal,
							step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
							speed         = 50,
							max_size      = text_width,
						},
						wibox.widget {
							box_content_text_artist,
							layout        = wibox.container.scroll.horizontal,
							step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
							speed         = 50,
							max_size      = text_width,
						},
						{
							box_content_button_prev,
							box_content_button_playpause,
							box_content_button_next,
							spacing = dpi(18),
							layout  = wibox.layout.fixed.horizontal,
						},
						layout = wibox.layout.fixed.vertical,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				content_progessbar_container,
				layout = wibox.layout.align.vertical
			},
			bg                 = '#00000040',
			shape              = rounded_rectangle(s.shape_size / 2),
			shape_border_width = dpi(1),
			shape_border_color = (beautiful.nord4 or '#D8DEE9'),
			widget             = wibox.container.background,
		}

		awesome.connect_signal('qrlinux::media::get_song_status', function(status)
			local i = s.print_status_sym(status)
			if i or i == '' then
				box_content_button_playpause_text:set_text(i)
			end
		end)

		return(box_content_container)
	end
	local box_content_container = s.music_control_widget(dpi(250))

	box_content_container_margined = wibox.widget {
		box_content_container,
		top    = (s.shape_size + s.arrow_width),
		bottom = s.shape_size, right = s.shape_size, left = s.shape_size,
		widget = wibox.container.margin,
	}

	s.box:setup {
		{
			box_content_container_margined,
			layout = wibox.layout.flex.horizontal,
		},
		shape              = s.shape,
		shape_border_width = dpi(2),
		shape_border_color = (beautiful.nord4 or '#D8DEE9'),
		widget             = wibox.container.background,
	}

	-- Toggle the playing status when clicking on the button
	s.music_button:connect_signal('button::release', function(_, _, _, button)
		if button == 1 then
			awful.spawn('playerctl play-pause')
		elseif button == 3 then
			s.box.visible = not s.box.visible
			center = mouse.current_widget_geometry.x - ((s.box.width / 2) or 0)
			awful.placement.top_left(s.box, { margins = {top = dpi(48), left = center }, parent = s })
		end
	end)

	s.song_playing_status = ''
	awesome.connect_signal('qrlinux::media::get_song_status', function(status)
		--if not status or status == '' then status = '⏸' end
		local i = s.print_status_sym(status)
		if not i or i == '' then
			s.music_button.visible = false
		else
			s.music_button.visible = true
			s.set_song_title_icon('♫ ' .. i .. ' ')
		end
	end)
	awesome.emit_signal('qrlinux::media::get_song_status', '')

	-- Update the text whenever a new song gets played
	awesome.connect_signal('qrlinux::media::get_song_title', function(title)
		s.set_song_title_text(tostring(title))
	end)

	gears.timer {
		autostart = true,
		timeout   = 0.1,
		callback  = function()
			s.music_button_text:set_text(s.song_title_icon .. s.song_title_text)
		end
	}

	--[[
	--s.coverart = wibox.widget {
	--	{
	--		forced_width  = dpi(180),
	--		forced_height = dpi(180),
	--		resize        = true,
	--		image         = beautiful.awesome_icon,
	--		widget        = wibox.widget.imagebox,
	--	},
	--	shape  = rounded_rectangle(dpi(20)),
	--	widget = wibox.container.margin,
	--}

	--awesome.connect_signal("bling::playerctl::title_artist_album", function(title, artist, art_path, player_name)
	--	s.coverart.widget:set_image(gears.surface.load_uncached(art_path))
	--end)

	--get_cover(function(c)
	--	local cover = c:gsub('\n', '')
	--	gears.timer {
	--		autostart = true,
	--		callback  = function() s.testbox.widget = cover end
	--	}
	--end)

	--function s.song_info()
	--	local song_info = {}

	--	song_info.title = wibox.widget {
	--		font   = 'Source Sans Pro Bold 18',
	--		text   = 'No song',
	--		widget = wibox.widget.textbox,
	--	}

	--	song_info.artist = wibox.widget {
	--		font   = 'Source Sans Pro 12',
	--		text   = 'is playing',
	--		widget = wibox.widget.textbox,
	--	}

	--	--awesome.connect_signal('qrlinux::media::get_song_title', function(title)
	--	--	song_info.title:set_text(tostring(title))
	--	--end)

	--	--awesome.connect_signal('qrlinux::media::get_song_artist', function(artist)
	--	--	song_info.artist:set_text(tostring(artist))
	--	--end)

	--	song_info.widget = wibox.widget {
	--		{
	--			{
	--				{
	--					{
	--						{
	--							song_info.title,
	--							layout = wibox.layout.align.horizontal,
	--						},
	--						{
	--							song_info.artist,
	--							layout = wibox.layout.align.horizontal,
	--						},
	--						layout = wibox.layout.flex.vertical,
	--					},
	--					strategy = 'exact',
	--					width    = dpi(180),
	--					height   = dpi(60),
	--					widget   = wibox.container.constraint,
	--				},
	--				margins = dpi(5),
	--				widget  = wibox.container.margin,
	--			},
	--			bg     = '#404040',
	--			shape  = rounded_rectangle(dpi(10)),
	--			widget = wibox.container.background,
	--		},
	--		layout = wibox.layout.align.horizontal,
	--	}

	--	song_info.aligned_widget = {
	--		{
	--			s.song_info(),
	--			layout = wibox.layout.fixed.horizontal,
	--		},
	--		layout = wibox.layout.fixed.vertical,
	--	}

	--	return(song_info.widget)
	--end

	--s.song_info.widget.widget.widget:set_bg('#000000')
	--s.song_info:emit_signal('widget::redraw_needed')

	--s.box:setup {
	--	{
	--		{
	--			s.song_info(),
	--			layout = wibox.layout.fixed.horizontal,
	--		},
	--		layout = wibox.layout.fixed.vertical,
	--	},
	--	layout  = wibox.layout.flex.horizontal
	--}

	--buttonify(s.box)
	--awful.placement.top_right(s.box, { margins = {top = dpi(48), right = dpi(48)}, parent = s})

	--buttonify({widget = s.main.widget})

	--	return(sym)
	--end

	--gears.timer {
	--	autostart = true,
	--	callback  = function()
	--		get_song(function(song)
	--			if song == '' then
	--				s.main.visible = false -- Hide the widget if nothing is playing
	--			else
	--				s.main.visible = true
	--				get_status(function(status) s.content.widget.text = print_status_sym(status, false) .. song end)
	--				title = song
	--			end
	--		end)
	--	end
	--}

	--get_song(function(song)
	--	get_status(function(status)
	--		s.main:connect_signal("button::release", function(c, _, _, button)
	--			if     button == 1 then
	--				s.box.visible = not s.box.visible
	--			elseif button == 3 then
	--				awful.spawn('playerctl play-pause')
	--				s.content.widget.text = print_status_sym(status, true) .. song .. ' '
	--			end
	--		end)
	--	end)

	--	return(s.main)
	--end)
	--]]

	return s.music_button, s.music_control_widget
end

return(music_button)