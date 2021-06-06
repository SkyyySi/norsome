local rounded_rectangle = require('rounded_rectangle')
local buttonify         = require('buttonify')

local music_button
function music_button(s)
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

	s.content = wibox.widget {
		{
			text   = '⏸ ',
			--font   = 'Source Sans Pro Bold 12',
			widget = wibox.widget.textbox,
		},
		left   = dpi(6),
		right  = dpi(6),
		widget = wibox.container.margin,
	}

	s.main = wibox.widget {
		{{
				--s.content,
				text   = '⏸ ',
				widget = wibox.widget.textbox,
				layout = wibox.layout.align.horizontal,
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

	s.box = wibox {
		bg      = '#202020E0',
		type    = 'desktop',
		ontop   = true,
		visible = false,
		width   = dpi(300),
		height  = dpi(150),
		--shape   = rounded_rectangle(19)
	}

	s.coverart = wibox.widget {
		{
			forced_width  = dpi(180),
			forced_height = dpi(180),
			resize        = true,
			image         = beautiful.awesome_icon,
			widget        = wibox.widget.imagebox,
		},
		shape  = rounded_rectangle(dpi(20)),
		widget = wibox.container.margin,
	}

	--awesome.connect_signal("bling::playerctl::title_artist_album", function(title, artist, art_path, player_name)
	--	s.coverart.widget:set_image(gears.surface.load_uncached(art_path))
	--end)

	get_cover(function(c)
		local cover = c:gsub('\n', '')
		gears.timer {
			autostart = true,
			callback  = function() s.testbox.widget = cover end
		}
	end)

	function s.song_info()
		local song_info = {}

		song_info.title = wibox.widget {
			font   = 'Source Sans Pro Bold 18',
			text   = 'No song',
			widget = wibox.widget.textbox,
		}

		song_info.artist = wibox.widget {
			font   = 'Source Sans Pro 12',
			text   = 'is playing',
			widget = wibox.widget.textbox,
		}

		--awesome.connect_signal('qrlinux::media::get_song_title', function(title)
		--	song_info.title:set_text(tostring(title))
		--end)

		--awesome.connect_signal('qrlinux::media::get_song_artist', function(artist)
		--	song_info.artist:set_text(tostring(artist))
		--end)

		song_info.widget = wibox.widget {
			{
				{
					{
						{
							{
								song_info.title,
								layout = wibox.layout.align.horizontal,
							},
							{
								song_info.artist,
								layout = wibox.layout.align.horizontal,
							},
							layout = wibox.layout.flex.vertical,
						},
						strategy = 'exact',
						width    = dpi(180),
						height   = dpi(60),
						widget   = wibox.container.constraint,
					},
					margins = dpi(5),
					widget  = wibox.container.margin,
				},
				bg     = '#404040',
				shape  = rounded_rectangle(dpi(10)),
				widget = wibox.container.background,
			},
			layout = wibox.layout.align.horizontal,
		}

		song_info.aligned_widget = {
			{
				s.song_info(),
				layout = wibox.layout.fixed.horizontal,
			},
			layout = wibox.layout.fixed.vertical,
		}

		return(song_info.widget)
	end

	--s.song_info.widget.widget.widget:set_bg('#000000')
	--s.song_info:emit_signal('widget::redraw_needed')

	s.box:setup {
		{
			{
				s.song_info(),
				layout = wibox.layout.fixed.horizontal,
			},
			layout = wibox.layout.fixed.vertical,
		},
		layout  = wibox.layout.flex.horizontal
	}

	--buttonify(s.box)
	awful.placement.top_right(s.box, { margins = {top = dpi(48), right = dpi(48)}, parent = s})

	buttonify({widget = s.main.widget})

	local print_status_sym
	function print_status_sym(stat, inv)
		local sym
		local playing = ' ♫ ⏸ '
		local paused  = ' ♫ ⏵ '

		if inv == true then
			local paused_tmp = paused
			paused  = playing
			playing = paused_tmp
		end

		if     stat == 'Playing\n' then sym = playing
		elseif stat == 'Paused\n'  then sym = paused
		else sym = ''
		end

		return(sym)
	end

	gears.timer {
		autostart = true,
		callback  = function()
			get_song(function(song)
				if song == '' then
					s.main.visible = false -- Hide the widget if nothing is playing
				else
					s.main.visible = true
					get_status(function(status) s.content.widget.text = print_status_sym(status, false) .. song end)
					title = song
				end
			end)
		end
	}

	get_song(function(song)
		get_status(function(status)
			s.main:connect_signal("button::release", function(c, _, _, button)
				if     button == 1 then
					s.box.visible = not s.box.visible
				elseif button == 3 then
					awful.spawn('playerctl play-pause')
					s.content.widget.text = print_status_sym(status, true) .. song .. ' '
				end
			end)
		end)

		return(s.main)
	end)

	return(s.main)
end

return(music_button)
