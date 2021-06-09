-- A function to create info bubbles with custom rounding sizes
local infobubble
function infobubble(size, arrow_size)
    local s = size       or dpi(10)
    local a = arrow_size or dpi(10)
    local shape
    function shape(cr, width, height)
        gears.shape.infobubble(cr, width, height, s, a)
    end
    return shape
end

return infobubble