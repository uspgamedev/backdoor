
local WALLMESH = {}

local SCHEMATICS = require 'domain.definitions.schematics'

local _mesh

--[[
+ [ ] Make normal walls
+ [ ] Hide off-camera ones
+ [ ] Divide in 9-patch, but keep drawing simple
+ [ ] Handle cases one by one
--]]

function WALLMESH.load(sector)
  local w, h = sector:getDimensions()
  local vertices = {}
  for i=1,h do
    for j=1,w do
      local tile = sector:getTile(i,j)
      if tile and tile.type == SCHEMATICS.WALL then
        --;
      end
    end
  end
end

function WALLMESH.draw()

end

return WALLMESH

