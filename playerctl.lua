local lgi = require('lgi')
title = lgi.Playerctl.Player{}:get_title()
title = title:gsub('%[.*%]', '')
print(title)