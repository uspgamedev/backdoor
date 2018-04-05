
local RES        = require 'resources'
local CAM        = require 'common.camera'
local SCHEMATICS = require 'domain.definitions.schematics'
local COLORS     = require 'domain.definitions.colors'
local VIEWDEFS   = require 'view.definitions'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _SEEN_ABYSS = COLORS.BACKGROUND * COLORS.HALF_VISIBLE

local TileMap = {}

local _sector
local _tile_batch
local _abyss_batch

function TileMap.init(sector, tileset)
  local pixel_texture = RES.loadTexture("pixel")
  local texture = RES.loadTexture(tileset.texture)
  _abyss_batch = love.graphics.newSpriteBatch(pixel_texture, 512, "stream")
  _tile_batch = love.graphics.newSpriteBatch(texture, 512, "stream")
  _tile_offset = tileset.offsets
  _tile_quads = tileset.quads
  _sector = sector
end

function TileMap.drawAbyss(g, fov)
  g.push()
  _abyss_batch:clear()
  for i, j in CAM:tilesInRange() do
    local ti, tj = i+1, j+1
    if _sector:isInside(ti, tj) then
      _abyss_batch:setColor(COLORS.BLACK)
      if fov and fov[ti] then
        local visibility = fov[ti][tj]
        if visibility then
          if visibility == 0 then
            _abyss_batch:setColor(_SEEN_ABYSS)
          else
            _abyss_batch:setColor(COLORS.BACKGROUND)
          end
        end
      end
      local x, y = j*_TILE_W, i*_TILE_H
      _abyss_batch:add(x, y, 0, _TILE_W, _TILE_H)
    end
  end
  g.draw(_abyss_batch, 0, 0)
  g.pop()
end

function TileMap.drawFloor(g, fov)
  -- draw flat tiles
  _tile_batch:clear()
  for i, j in CAM:tilesInRange() do
    local ti, tj = i+1, j+1 -- logic coordinates
    local tile = _sector.tiles[ti] and _sector.tiles[ti][tj]
    if tile then
      local tile_type = (tile.type == SCHEMATICS.WALL)
                        and SCHEMATICS.FLOOR or tile.type
      local x, y = j*_TILE_W, i*_TILE_H
      _tile_batch:setColor(COLORS.NEUTRAL)
      if fov and fov[ti] then
        local visibility = fov[ti][tj]
        if not visibility then
          _tile_batch:setColor(COLORS.BLACK)
        elseif visibility == 0 then
          _tile_batch:setColor(COLORS.HALF_VISIBLE)
        else
          _tile_batch:setColor(COLORS.NEUTRAL)
        end
      else
        error(string.format("No FOV in tile [%d, %d]", ti, tj))
      end
      _tile_batch:add(_tile_quads[tile_type], x, y,
                  0, 1, 1, unpack(_tile_offset[tile.type]))
    end
  end
  g.setColor(COLORS.NEUTRAL)
  g.draw(_tile_batch, 0, 0)
  _tile_batch:clear()
end

function TileMap.drawWallInLine(g, i, fov)
  -- to be implemented in v11.0
end

return TileMap

