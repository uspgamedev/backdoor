
local RES        = require 'resources'
local CAM        = require 'common.camera'
local SCHEMATICS = require 'domain.definitions.schematics'
local COLORS     = require 'domain.definitions.colors'
local VIEWDEFS   = require 'view.definitions'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H

local TileMap = {}

local _sector
local _tile_batch

function TileMap.init(sector, tileset)
  local texture = RES.loadTexture(tileset.texture)
  _tile_batch = love.graphics.newSpriteBatch(texture, 512, "stream")
  _tile_offset = tileset.offsets
  _tile_quads = tileset.quads
  _sector = sector
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
  _tile_batch:clear()
  for j = 0, _sector.w-1 do
    local ti, tj = i+1, j+1
    local tile = _sector.tiles[ti][tj]
    if CAM:isTileInFrame(i, j) and tile then
      local tile_tipe = tile.type
      if tile_type == SCHEMATICS.WALL then
        local x, y = j*_TILE_W, i*_TILE_H
        if fov and fov[ti] then
          local visibility = fov[ti][tj]
          if not visibility then
            _tile_batch:setColor(COLORS.BLACK)
          elseif visibility == 0 then
            _tile_batch:setColor(COLORS.HALF_VISIBLE)
          else
            _tile_batch:setColor(COLORS.NEUTRAL)
          end
          _tile_batch:add(_tile_quads[tile_type], x, y,
                          0, 1, 1, unpack(_tile_offset[tile_type]))
        end
      end
    end
  end
  g.setColor(COLORS.NEUTRAL)
  g.draw(_tile_batch, 0, 0)
  _tile_batch:clear()
end

return TileMap

