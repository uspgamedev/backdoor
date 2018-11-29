
local fs = love.filesystem
fs.setRequirePath("libs/?/init.lua;libs/?.lua;"..fs.getRequirePath())
--Steaming is a special case
fs.setRequirePath("libs/steaming/?.lua;"..fs.getRequirePath())
fs.setCRequirePath(fs.getSourceBaseDirectory().."/?.so;"..fs.getCRequirePath())
fs.setCRequirePath(fs.getSourceBaseDirectory().."/?.dll;"..fs.getCRequirePath())
