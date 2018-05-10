
local WALLMESH = {}

local SCHEMATICS  = require 'domain.definitions.schematics'
local VIEWDEFS    = require 'view.definitions'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _WALL_H = 40
local _FRONT_COLOR = {31/256, 44/256, 38/256, 1}
local _TOP_COLOR   = {43/256, 100/256, 112/256, 1}
local _W, _H
local _MAX_VTX = 512

local _walldata
local _vertices
local _mesh

--[[
+ [ ] Make normal walls
+ [ ] Hide off-camera ones
+ [ ] Divide in 9-patch, but keep drawing simple
+ [ ] Handle cases one by one
--]]

local function _wallidx(i, j)
  return (i-1)*_W + j
end

local function _vtx(x, y, color)
  return {x, y, 0, 0, unpack(color)}
end

function WALLMESH.load(sector)
  local count = 0
  _W, _H = sector:getDimensions()
  _vertices = {}
  _walldata = {}
  for i=1,_H do
    for j=1,_W do
      local tile = sector:getTile(i,j)
      local wall = false
      if tile and tile.type == SCHEMATICS.WALL then
        local base = 8*count
        local x = (j-1)*_TILE_W
        local y = _TILE_H - _WALL_H
        count = count + 1
        -- wall front (topleft, topright, bottomleft, bottomright)
        table.insert(_vertices, _vtx(x, y, _FRONT_COLOR))
        table.insert(_vertices, _vtx(x + _TILE_W, y, _FRONT_COLOR))
        table.insert(_vertices, _vtx(x, y + _WALL_H, _FRONT_COLOR))
        table.insert(_vertices, _vtx(x + _TILE_W, y + _WALL_H, _FRONT_COLOR))
        -- wall top (topleft, topright, bottomleft, bottomright)
        y = y - _TILE_H
        table.insert(_vertices, _vtx(x, y, _TOP_COLOR))
        table.insert(_vertices, _vtx(x + _TILE_W, y, _TOP_COLOR))
        table.insert(_vertices, _vtx(x, y + _TILE_H, _TOP_COLOR))
        table.insert(_vertices, _vtx(x + _TILE_W, y + _TILE_H, _TOP_COLOR))
        wall = { base+1, base+2, base+3,
                 base+2, base+4, base+3,
                 base+5, base+6, base+7,
                 base+6, base+8, base+7 }
      end
      table.insert(_walldata, wall)
    end
  end
  _mesh = love.graphics.newMesh(_MAX_VTX, 'triangles', 'stream')
end

local _NULL_VTX = {0, 0, 0, 0, 0, 0, 0, 0}

function WALLMESH.drawRow(i, mask)
  assert(_mesh)
  local vertices = {}
  local count = 0
  for j,check in ipairs(mask) do
    if check then
      local wall = _walldata[_wallidx(i, j)] if wall then
        for _,vtx in ipairs(wall) do
          local vertex = { unpack(_vertices[vtx]) }
          if check < 1 then
            vertex[5] = vertex[5] * 0.5
            vertex[6] = vertex[6] * 0.5
            vertex[7] = vertex[7] * 0.5
          end
          table.insert(vertices, vertex)
          count = count + 1
        end
      end
    end
  end
  assert(count <= _MAX_VTX)
  if count > 0 then
    for i=count+1,_MAX_VTX do
      vertices[i] = _NULL_VTX
    end
    _mesh:setVertices(vertices)
    love.graphics.draw(_mesh, 0, 0)
  end
end

return WALLMESH

