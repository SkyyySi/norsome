-- Convert HSL (hue saturation lightness) to RGB (red green blue)
-- Original code by John Chin-Jew/Wavalab:
-- https://github.com/Wavalab/rgb-hsl-rgb

local hslToHex
function hslToHex(h, s, l, a)
	a = a or nil
	local r, g, b

	if s == 0 then
		r, g, b = l, l, l -- achromatic
	else
		function hue2rgb(p, q, t)
		if t < 0   then t = t + 1 end
		if t > 1   then t = t - 1 end
		if t < 1/6 then return p + (q - p) * 6 * t end
		if t < 1/2 then return q end
		if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
		return p
	end

	local q
	if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
		local p = 2 * l - q

		r = hue2rgb(p, q, h + 1/3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1/3)
	end

	local out_r, out_b, out_g
	out_r = string.format('%x', round(r * 255))
	if (#out_r < 2) then out_r = '0'..out_r end
	out_g = string.format('%x', round(g * 255))
	if (#out_g < 2) then out_g = '0'..out_g end
	out_b = string.format('%x', round(b * 255))
	if (#out_b < 2) then out_b = '0'..out_b end
	local out = ''
	out = (out_r .. out_g .. out_b)
	if a then out = out .. string.format('%x', round(a * 255)) end
	--if (#out < 6) then out = '0'..out end
	return(tostring('#'..out))
end

--[[
local bg = 0
gears.timer {
	autostart = false,
	callback  = function()
		if bg >= 1 then bg = 0 end
		print('Color: '..hslToHex(bg, 1, 0.5, 1))
		bg = bg + 0.01
	end
}

hslToHex(0.5, 0.5, 0.5, 0.8)
--]]

return(hslToHex)