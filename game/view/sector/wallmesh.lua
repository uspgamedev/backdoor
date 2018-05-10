
local WALLMESH = {}

local SCHEMATICS  = require 'domain.definitions.schematics'
local VIEWDEFS    = require 'view.definitions'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _WALL_H = 80
local _MARGIN_W = 8
local _MARGIN_H = 6
local _GRID_W = 20
local _GRID_H = 15

local _BACK_COLOR = {31/256, 44/256, 38/256, 0.4}
local _FRONT_COLOR = {31/256, 44/256, 38/256, 1}
local _TOP_COLOR   = {43/256, 100/256, 112/256, 1}

local _W, _H
local _MAX_VTX = 1024
local _QUADFACES = {1, 2, 3, 2, 4, 3}

local _walldata
local _vertices
local _mesh

--[[
+ [x] Make normal walls
+ [x] Hide off-camera ones
+ [x] Divide in 9-patch, but keep drawing simple
+ [ ] Handle cases one by one
--]]

local function _wallidx(i, j)
  return (i-1)*_W + j
end

local function _vtx(x, y, color)
  return {x, y, 0, 0, unpack(color)}
end

local function _concat(t1, t2)
  local n = #t1
  for i,v in ipairs(t2) do
    t1[n+i] = v
  end
end

local function _quad(x, y, w, h, color)
  return {
    _vtx(x, y, color), _vtx(x+w, y, color),
    _vtx(x, y+h, color), _vtx(x+w, y+h, color)
  }
end

local function _custom(color, x1, y1, x2, y2, x3, y3, x4, y4)
  return {
    _vtx(x1, y1, color), _vtx(x2, y2, color),
    _vtx(x3, y3, color), _vtx(x4, y4, color)
  }
end

local function _quadFaces(base)
  local faces = {}
  for i,v in ipairs(_QUADFACES) do
    faces[i] = v + base
  end
  return faces
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

local function _makeQuad(wall, count, x, y, w, h, color)
  _concat(_vertices, _quad(x, y, w, h, color))
  _concat(wall, _quadFaces(count))
  return count + 4
end

local function _makeCustom(wall, count, ...)
  _concat(_vertices, _custom(...))
  _concat(wall, _quadFaces(count))
  return count + 4
end

function WALLMESH.load(sector)
  local count = 0
  _W, _H = sector:getDimensions()
  _vertices = {}
  _walldata = {}
  for i=1,_H do
    for j=1,_W do
      local neighbors = _neighbors(sector, i, j)
      local tile = sector:getTile(i,j)
      local wall = false
      if tile and tile.type == SCHEMATICS.WALL then
        local x0 = (j-1)*_TILE_W
        local y0 = 0
        wall = {}

        -- top
        if _empty(neighbors, 1, 2) then
          local x = x0 + _GRID_W
          local y = y0 + _MARGIN_H - _WALL_H
          count = _makeQuad(wall, count, x, y, _TILE_W - 2*_GRID_W, _WALL_H,
                            _BACK_COLOR)
          count = _makeQuad(wall, count, x, y, _TILE_W - 2*_GRID_W, _MARGIN_H,
                            _TOP_COLOR)
        end

        -- topleft
        if _walled(neighbors, 2, 1) and _empty(neighbors, 1, 2) then
          -- straight left
          local x = x0
          local y = y0 + _MARGIN_H - _WALL_H
          count = _makeQuad(wall, count, x, y, _GRID_W, _WALL_H, _BACK_COLOR)
          count = _makeQuad(wall, count, x, y, _GRID_W, _MARGIN_H, _TOP_COLOR)
        elseif _walled(neighbors, 1, 2) and _empty(neighbors, 2, 1) then
          -- straight up
          local x = x0 + _MARGIN_W
          local y = y0 - _WALL_H
          count = _makeQuad(wall, count, x, y, _MARGIN_W, _GRID_H, _TOP_COLOR)
        elseif _empty(neighbors, 2, 1) and _empty(neighbors, 1, 2) then
          -- outer corner
          local x = x0
          local y = y0 - _WALL_H
          count = _makeCustom(wall, count, _BACK_COLOR,
                              x + _MARGIN_W, y + _GRID_H,
                              x + _GRID_W, y + _MARGIN_H,
                              x + _MARGIN_W, y + _GRID_H + _WALL_H,
                              x + _GRID_W, y + _MARGIN_H + _WALL_H)
          count = _makeCustom(wall, count, _TOP_COLOR,
                              x + _MARGIN_W, y + _GRID_H,
                              x + _GRID_W, y + _MARGIN_H,
                              x + 2*_MARGIN_W, y + _GRID_H,
                              x + _GRID_W, y + 2*_MARGIN_H)
        end

        -- topright
        if _walled(neighbors, 2, 3) and _empty(neighbors, 1, 2) then
          -- straight right
          local x = x0 + _TILE_W - _GRID_W
          local y = y0 + _MARGIN_H - _WALL_H
          count = _makeQuad(wall, count, x, y, _GRID_W, _WALL_H, _BACK_COLOR)
          count = _makeQuad(wall, count, x, y, _GRID_W, _MARGIN_H, _TOP_COLOR)
        elseif _walled(neighbors, 1, 2) and _empty(neighbors, 2, 3) then
          -- straight up
          local x = x0 + _TILE_W - 2*_MARGIN_W
          local y = y0 - _WALL_H
          count = _makeQuad(wall, count, x, y, _MARGIN_W, _GRID_H, _TOP_COLOR)
        elseif _empty(neighbors, 1, 2) and _empty(neighbors, 2, 3) then
          -- outer corner
          local x = x0 + _TILE_W
          local y = y0 - _WALL_H
          count = _makeCustom(wall, count, _BACK_COLOR,
                              x - _GRID_W, y + _MARGIN_H,
                              x - _MARGIN_W, y + _GRID_H,
                              x - _GRID_W, y + _MARGIN_H + _WALL_H,
                              x - _MARGIN_W, y + _GRID_H + _WALL_H)
          count = _makeCustom(wall, count, _TOP_COLOR,
                              x - _GRID_W, y + _MARGIN_H,
                              x - _MARGIN_W, y + _GRID_H,
                              x - _GRID_W, y + 2*_MARGIN_H,
                              x - 2*_MARGIN_W, y + _GRID_H)
        end

        -- left
        if _empty(neighbors, 2, 1) then
          local x = x0 + _MARGIN_W
          local y = y0 + _GRID_H - _WALL_H
          count = _makeQuad(wall, count, x, y, _MARGIN_W, _TILE_H - 2*_GRID_H,
                            _TOP_COLOR)
        end

        -- right
        if _empty(neighbors, 2, 3) then
          local x = x0 + _TILE_W - 2*_MARGIN_W
          local y = y0 + _GRID_H - _WALL_H
          count = _makeQuad(wall, count, x, y, _MARGIN_W, _TILE_H - 2*_GRID_H,
                            _TOP_COLOR)
        end

        -- front
        if _empty(neighbors, 3, 2) then
          local x = x0 + _GRID_W
          local y = y0 + _TILE_H - _MARGIN_H - _WALL_H
          count = _makeQuad(wall, count, x, y, _TILE_W - 2*_GRID_W, _WALL_H,
                            _FRONT_COLOR)
          count = _makeQuad(wall, count, x, y - _MARGIN_H, _TILE_W - 2*_GRID_W,
                            _MARGIN_H, _TOP_COLOR)
        end

        -- bottomleft
        if _walled(neighbors, 2, 1) and _empty(neighbors, 3, 2) then
          -- straight left
          local x = x0
          local y = y0 + _TILE_H - _MARGIN_H - _WALL_H
          count = _makeQuad(wall, count, x, y, _GRID_W, _WALL_H, _FRONT_COLOR)
          count = _makeQuad(wall, count, x, y - _MARGIN_H, _GRID_W,
                            _MARGIN_H, _TOP_COLOR)
        elseif _walled(neighbors, 3, 2) and _empty(neighbors, 2, 1) then
          -- straight down
          local x = x0 + _MARGIN_W
          local y = y0 + _TILE_H - _WALL_H - _GRID_H
          count = _makeQuad(wall, count, x, y, _MARGIN_W, _GRID_H, _TOP_COLOR)
        elseif _empty(neighbors, 2, 1) and _empty(neighbors, 3, 2) then
          -- outer corner
          local x = x0
          local y = y0 + _TILE_H - _WALL_H
          count = _makeCustom(wall, count, _FRONT_COLOR,
                              x + _MARGIN_W, y - _GRID_H,
                              x + _GRID_W, y - _MARGIN_H,
                              x + _MARGIN_W, y - _GRID_H + _WALL_H,
                              x + _GRID_W, y - _MARGIN_H + _WALL_H)
          count = _makeCustom(wall, count, _TOP_COLOR,
                              x + _MARGIN_W, y - _GRID_H,
                              x + 2*_MARGIN_W, y - _GRID_H,
                              x + _GRID_W, y - _MARGIN_H,
                              x + _GRID_W, y - 2*_MARGIN_H)
        end

        -- bottomright
        if _walled(neighbors, 2, 3) and _empty(neighbors, 3, 2) then
          -- straight right
          local x = x0 + _TILE_W - _GRID_W
          local y = y0 + _TILE_H - _MARGIN_H - _WALL_H
          count = _makeQuad(wall, count, x, y, _GRID_W, _WALL_H, _FRONT_COLOR)
          count = _makeQuad(wall, count, x, y - _MARGIN_H, _GRID_W,
                            _MARGIN_H, _TOP_COLOR)
        elseif _walled(neighbors, 3, 2) and _empty(neighbors, 2, 3) then
          -- straight down
          local x = x0 + _TILE_W - 2*_MARGIN_W
          local y = y0 + _TILE_H - _WALL_H - _GRID_H
          count = _makeQuad(wall, count, x, y, _MARGIN_W, _GRID_H, _TOP_COLOR)
        elseif _empty(neighbors, 2, 3) and _empty(neighbors, 3, 2) then
          -- outer corner
          local x = x0 + _TILE_W
          local y = y0 + _TILE_H - _WALL_H
          count = _makeCustom(wall, count, _FRONT_COLOR,
                              x - _GRID_W, y - _MARGIN_H,
                              x - _MARGIN_W, y - _GRID_H,
                              x - _GRID_W, y - _MARGIN_H + _WALL_H,
                              x - _MARGIN_W, y - _GRID_H + _WALL_H)
          count = _makeCustom(wall, count, _TOP_COLOR,
                              x - 2*_MARGIN_W, y - _GRID_H,
                              x - _MARGIN_W, y - _GRID_H,
                              x - _GRID_W, y - 2*_MARGIN_H,
                              x - _GRID_W, y - _MARGIN_H)
        end
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

