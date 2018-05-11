
local WALL = {}

local SCHEMATICS  = require 'domain.definitions.schematics'
local VIEWDEFS    = require 'view.definitions'

local vec2        = require 'cpml' .vec2
local WallMesh    = require 'view.sector.mesh.wall'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _WALL_H = 80
local _MARGIN_W = 12
local _MARGIN_H = 8
local _BORDER_W = 8
local _BORDER_H = 6
local _GRID_W = 24
local _GRID_H = 18

local _TOPLEFT = vec2(0,0)
local _TOPRIGHT = vec2(_TILE_W, 0)
local _BOTLEFT = vec2(0, _TILE_H)
local _BOTRIGHT = vec2(_TILE_W, _TILE_H)

local _BACK_COLOR = {31/256, 44/256, 38/256, 0.4}
local _FRONT_COLOR = {31/256, 44/256, 38/256, 1}
local _TOP_COLOR   = {43/256, 100/256, 112/256, 1}

local _W, _H
local _MAX_VTX = 2048

local _walldata
local _mesh

local function _wallidx(i, j)
  return (i-1)*_W + j
end

local function _neighbors(sector, i, j)
  local neighbors = {}
  for r=1,3 do
    local di = r - 2
    neighbors[r] = {}
    for s=1,3 do
      local dj = s - 2
      neighbors[r][s] = sector:isInside(i + di, j + dj)
                        and sector:getTile(i + di, j + dj)
                        or false
    end
  end
  return neighbors
end

local function _empty(neighbors, r, s)
  return not neighbors[r][s] or neighbors[r][s].type ~= SCHEMATICS.WALL
end

local function _walled(neighbors, r, s)
  return neighbors[r][s] and neighbors[r][s].type == SCHEMATICS.WALL
end

function WALL.load(sector)
  local count = 0
  _W, _H = sector:getDimensions()
  _walldata = {}
  for i=1,_H do
    for j=1,_W do
      local neighbors = _neighbors(sector, i, j)
      local tile = sector:getTile(i,j)
      local wall = false
      if tile and tile.type == SCHEMATICS.WALL then
        local x0 = (j-1)*_TILE_W
        local y0 = 0
        wall = WallMesh:new { pos = vec2(x0,y0), border_color = _TOP_COLOR }

        -- top
        if _empty(neighbors, 1, 2) then
          wall:addSide(_BACK_COLOR, vec2(_GRID_W, _MARGIN_H),
                                    vec2(_TILE_W - _GRID_W, _MARGIN_H),
                                    vec2(0, _BORDER_H))
        end

        -- topleft
        if _walled(neighbors, 2, 1) and _empty(neighbors, 1, 2) then
          -- straight left
          wall:addSide(_BACK_COLOR, vec2(0, _MARGIN_H),
                                    vec2(_GRID_W, _MARGIN_H),
                                    vec2(0, _BORDER_H))
        elseif _walled(neighbors, 1, 2) and _empty(neighbors, 2, 1) then
          -- straight up
          wall:addSide(nil, vec2(_MARGIN_W, 0), vec2(_MARGIN_W, _GRID_H),
                            vec2(_BORDER_W, 0)) 
        elseif _empty(neighbors, 2, 1) and _empty(neighbors, 1, 2) then
          -- outer corner
          wall:addSide(_BACK_COLOR, vec2(_MARGIN_W, _GRID_H),
                                    vec2(_GRID_W, _MARGIN_H),
                                    vec2(_BORDER_W, 0), vec2(0, _BORDER_H))
        elseif _walled(neighbors, 2, 1) and _walled(neighbors, 1, 2) and
               _empty(neighbors, 1, 1) then
          -- inner corner
          wall:addSide(_BACK_COLOR, vec2(0, _MARGIN_H), vec2(_MARGIN_W, 0),
                                    vec2(0, _BORDER_H), vec2(_BORDER_W, 0))
        end

        -- topright
        if _walled(neighbors, 2, 3) and _empty(neighbors, 1, 2) then
          -- straight right
          wall:addSide(_BACK_COLOR, vec2(_TILE_W - _GRID_W, _MARGIN_H),
                                    vec2(_TILE_W, _MARGIN_H),
                                    vec2(0, _BORDER_H))
        elseif _walled(neighbors, 1, 2) and _empty(neighbors, 2, 3) then
          -- straight up
          wall:addSide(nil, vec2(_TILE_W - _MARGIN_W, 0),
                            vec2(_TILE_W - _MARGIN_W, _GRID_H),
                            vec2(-_BORDER_W, 0)) 
        elseif _empty(neighbors, 1, 2) and _empty(neighbors, 2, 3) then
          -- outer corner
          wall:addSide(_BACK_COLOR, vec2(_TILE_W - _MARGIN_W, _GRID_H),
                                    vec2(_TILE_W - _GRID_W, _MARGIN_H),
                                    vec2(-_BORDER_W, 0), vec2(0, _BORDER_H))
        elseif _walled(neighbors, 1, 2) and _walled(neighbors, 2, 3) and
               _empty(neighbors, 1, 3) then
          -- inner corner
          wall:addSide(_BACK_COLOR, vec2(_TILE_W, _MARGIN_H),
                                    vec2(_TILE_W - _MARGIN_W, 0),
                                    vec2(0, _BORDER_H), vec2(-_BORDER_W, 0))
        end

        -- left
        if _empty(neighbors, 2, 1) then
          local border = vec2(_BORDER_W,0)
          wall:addSide(nil, vec2(_MARGIN_W, _GRID_H),
                            vec2(_MARGIN_W, _TILE_H - _GRID_H), border)
        end

        -- right
        if _empty(neighbors, 2, 3) then
          local border = vec2(-_BORDER_W,0)
          wall:addSide(nil, vec2(_TILE_W - _MARGIN_W, _GRID_H),
                            vec2(_TILE_W - _MARGIN_W, _TILE_H - _GRID_H),
                            border)
        end

        -- front
        if _empty(neighbors, 3, 2) then
          wall:addSide(_FRONT_COLOR, _BOTLEFT + vec2(_GRID_W, -_MARGIN_H),
                                     _BOTRIGHT - vec2(_GRID_W, _MARGIN_H),
                                     vec2(0, -_BORDER_H))
        end

        -- bottomleft
        if _walled(neighbors, 2, 1) and _empty(neighbors, 3, 2) then
          -- straight left
          wall:addSide(_FRONT_COLOR, _BOTLEFT - vec2(0, _MARGIN_H),
                                     _BOTLEFT + vec2(_GRID_W, -_MARGIN_H),
                                     vec2(0, -_BORDER_H))
        elseif _walled(neighbors, 3, 2) and _empty(neighbors, 2, 1) then
          -- straight down
          wall:addSide(nil, _BOTLEFT + vec2(_MARGIN_W, -_GRID_H),
                            _BOTLEFT + vec2(_MARGIN_W, 0),
                            vec2(_BORDER_W, 0))
        elseif _empty(neighbors, 2, 1) and _empty(neighbors, 3, 2) then
          -- outer corner
          wall:addSide(_FRONT_COLOR, _BOTLEFT + vec2(_MARGIN_W, -_GRID_H),
                                     _BOTLEFT + vec2(_GRID_W, -_MARGIN_H),
                                     vec2(_BORDER_W, 0), vec2(0, -_BORDER_H))
        elseif _walled(neighbors, 2, 1) and _walled(neighbors, 3, 2) and
               _empty(neighbors, 3, 1) then
          -- inner corner
          wall:addSide(_FRONT_COLOR, _BOTLEFT + vec2(0, -_MARGIN_H),
                                     _BOTLEFT + vec2(_MARGIN_W, 0),
                                     vec2(0, -_BORDER_H), vec2(_BORDER_W, 0))
        end

        -- bottomright
        if _walled(neighbors, 2, 3) and _empty(neighbors, 3, 2) then
          -- straight right
          wall:addSide(_FRONT_COLOR, _BOTRIGHT - vec2(0, _MARGIN_H),
                                     _BOTRIGHT - vec2(_GRID_W, _MARGIN_H),
                                     vec2(0, -_BORDER_H))
        elseif _walled(neighbors, 3, 2) and _empty(neighbors, 2, 3) then
          -- straight down
          wall:addSide(nil, _BOTRIGHT - vec2(_MARGIN_W, _GRID_H),
                            _BOTRIGHT - vec2(_MARGIN_W, 0),
                            vec2(-_BORDER_W, 0))
        elseif _empty(neighbors, 2, 3) and _empty(neighbors, 3, 2) then
          -- outer corner
          wall:addSide(_FRONT_COLOR, _BOTRIGHT - vec2(_MARGIN_W, _GRID_H),
                                     _BOTRIGHT - vec2(_GRID_W, _MARGIN_H),
                                     vec2(-_BORDER_W, 0), vec2(0, -_BORDER_H))
        elseif _walled(neighbors, 2, 3) and _walled(neighbors, 3, 2) and
               _empty(neighbors, 3, 3) then
          -- inner corner
          wall:addSide(_FRONT_COLOR, _BOTRIGHT - vec2(0, _MARGIN_H),
                                     _BOTRIGHT - vec2(_MARGIN_W, 0),
                                     vec2(0, -_BORDER_H), vec2(-_BORDER_W, 0))
        end
      end
      table.insert(_walldata, wall)
    end
  end
  _mesh = love.graphics.newMesh(_MAX_VTX, 'triangles', 'stream')
end

local _NULL_VTX = {0, 0, 0, 0, 0, 0, 0, 0}

function WALL.drawRow(i, mask)
  assert(_mesh)
  local vertices = {}
  local count = 0
  for j,check in ipairs(mask) do
    local wall = _walldata[_wallidx(i, j)] if wall then
      for _,idx in wall:map() do
        local vertex = wall:getVertex(idx)
        if check and check < 1 then
          vertex[5] = vertex[5] * 0.5
          vertex[6] = vertex[6] * 0.5
          vertex[7] = vertex[7] * 0.5
        elseif not check then
          vertex[5] = 0
          vertex[6] = 0
          vertex[7] = 0
        end
        table.insert(vertices, vertex)
        count = count + 1
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

return WALL

