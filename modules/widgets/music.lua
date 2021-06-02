local rounded_rectangle = require('rounded_rectangle')
local buttonify         = require('buttonify')

local notify
function notify(...)
	for v, i in ipairs(arg) do
		naughty.notify({text = tostring(v)})
	end
end

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
		left   = 6,
		right  = 6,
		widget = wibox.container.margin,
	}

	s.main = wibox.widget {
		{{
				s.content,
				layout = wibox.layout.align.horizontal,
			},
			bg                 = beautiful.button_normal,
			shape              = gears.shape.rounded_bar,
			shape_border_width = 1,
			shape_border_color = beautiful.nord4,
			widget             = wibox.container.background,
		},
		margins = 4,
		widget  = wibox.container.margin,
		visible = true,
	}

	s.box = wibox {
		bg      = '#202020E0',
		type    = 'desktop',
		ontop   = true,
		visible = false,
		width   = 300,
		height  = 150,
		--shape   = rounded_rectangle(19)
	}

	s.coverart = wibox.widget {
		{
			forced_width  = 180,
			forced_height = 180,
			resize        = true,
			image         = beautiful.awesome_icon,
			widget        = wibox.widget.imagebox,
		},
		shape  = rounded_rectangle(20),
		widget = wibox.container.margin,
	}

	awesome.connect_signal("bling::playerctl::title_artist_album", function(title, artist, art_path, player_name)
		s.coverart.widget:set_image(gears.surface.load_uncached(art_path))
	end)

	get_cover(function(c)
		local cover = c:gsub('\n', '')
		gears.timer {
			autostart = true,
			callback  = function() s.testbox.widget = cover end
		}
	end)

	--s.song_info = wibox.widget {}
	function s.song_info()
		local song_info
		get_song(function(title)
			get_artist(function(artist)
				song_info = wibox.widget {
					{
						orientation   = 'vertical',
						forced_width  = 40,
						forced_height = 40,
						thickness     = 10,
						color         = '#FF0000', --red
						widget = wibox.widget.separator,
					},
					{
						{
							orientation   = 'horizontal',
							forced_width  = 40,
							forced_height = 40,
							thickness     = 10,
							color         = '#00FF00', --green
							widget = wibox.widget.separator,
						},
						{{{{{
											before,
											font   = 'Source Sans Pro Bold 18',
											text   = 'title',
											widget = wibox.widget.textbox,
										},
										{
											after,
											font   = 'Source Sans Pro 12',
											text   = 'artist',
											widget = wibox.widget.textbox,
										},
										layout = wibox.layout.flex.vertical,
									},
									strategy = 'exact',
									width    = 180,
									height   = 60,
									widget   = wibox.container.constraint,
								},
								margins = 5,
								widget  = wibox.container.margin,
							},
							bg     = '#404040',
							shape  = rounded_rectangle(10),
							widget = wibox.container.background,
						},
						layout = wibox.layout.align.horizontal,
					},
					layout = wibox.layout.align.vertical,
				}
				naughty.notify({text = song_info})
				return(song_info)
			end)
			return(song_info)
		end)
		return(song_info)
	end

	--s.song_info.widget.widget.widget:set_bg('#000000')
	--s.song_info:emit_signal('widget::redraw_needed')

	s.box:setup {
		{
			{
				s.song_info(),
				layout = wibox.layout.align.horizontal,
			},
			layout = wibox.layout.align.vertical,
		},
		layout = wibox.layout.stack
	}

	--buttonify(s.box)
	awful.placement.top_right(s.box, { margins = {top = 48, right = 48}, parent = s})

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

	awful.widget.watch('true', 0.2, function()
		get_song(function(song)
			if song == '' then
				s.main.visible = false -- Hide the widget if nothing is playing
			else
				s.main.visible = true
				get_status(function(status) s.content.widget.text = print_status_sym(status, false) .. song end)
				title = song
			end
		end)
	end)

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
