
local fs = love.filesystem
fs.setRequirePath("libs/?/init.lua;libs/?.lua;"..fs.getRequirePath())
package.cpath = fs.getSourceBaseDirectory().."/?.so;" .. package.cpath

