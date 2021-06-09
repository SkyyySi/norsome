-- This library contains some basic functionality

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