
local fs = love.filesystem
fs.setRequirePath("libs/?/init.lua;libs/?.lua;"..fs.getRequirePath())
fs.setCRequirePath(fs.getSourceBaseDirectory().."/?.so;"..fs.getCRequirePath())

