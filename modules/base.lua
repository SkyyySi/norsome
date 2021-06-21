-- This library contains some basic functionality

function round(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

filecheck = {}

function filecheck.read(name)
	local f = io.open(name,'r')
	if f ~= nil then io.close(f) return(true) else return(false) end
end

function filecheck.write(name)
	local f = io.open(name,'w')
	if f ~= nil then io.close(f) return(true) else return(false) end
end

function filecheck.exec(name)
	local f = io.open(name,'x')
	if f ~= nil then io.close(f) return(true) else return(false) end
end