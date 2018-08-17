
local RES        = require 'resources'
local CAM        = require 'common.camera'
local SCHEMATICS = require 'domain.definitions.schematics'
local COLORS     = require 'domain.definitions.colors'
local VIEWDEFS   = require 'view.definitions'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _VIEW_W = VIEWDEFS.HALF_W*2 - 2
local _VIEW_H = VIEWDEFS.HALF_H*2 - 2
local _SEEN_ABYSS = COLORS.BACKGROUND * COLORS.HALF_VISIBLE

local _FXCODE = [[
uniform Image mask;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 pos) {
  vec2 p = pos/love_ScreenSize.xy;
  return color * Texel(tex, uv) * Texel(mask, p);
}
]]
local _FXSHADER

local TILEMAP = {}

local _sector
local _tile_batch
local _fovmask
local _tilemask

function TILEMAP.init(sector, tileset)
  local pixel_texture = RES.loadTexture("pixel")
  local texture = RES.loadTexture(tileset.texture)
  _tile_batch = love.graphics.newSpriteBatch(texture, 512, "stream")
  _tile_offset = tileset.offsets
  _tile_quads = tileset.quads
  _sector = sector
  _fovmask = love.graphics.newCanvas(_VIEW_W * _TILE_W, _VIEW_H * _TILE_H)
  _FXSHADER = _FXSHADER or love.graphics.newShader(_FXCODE)
  if not _tilemask then
    local data = love.image.newImageData(_TILE_W*3, _TILE_H*3)
    data:mapPixel(
      function (x, y)
        y = y*_TILE_W/_TILE_H
        local px = math.max(_TILE_W, math.min(2*_TILE_W, x))
        local py = math.max(_TILE_W, math.min(2*_TILE_W, y))
        local d = math.sqrt((x - px)^2 + (y - py)^2)/_TILE_W*2
        local c = math.max(0, (1-d^2))
        return c, c, c, 1
      end
    )
    _tilemask = love.graphics.newImage(data)
  end
end

function TILEMAP.calculateFOVMask(g, fov)
  g.setCanvas(_fovmask)
  g.clear()
  g.setColor(COLORS.BLACK)

  g.push()
  g.origin()
  g.rectangle('fill', 0, 0, _fovmask:getWidth(), _fovmask:getHeight())
  g.pop()

  g.setBlendMode('lighten', 'premultiplied')
  for i, j in CAM:tilesInRange() do
    local ti, tj = i+1, j+1 -- logic coordinates
    local x, y = j*_TILE_W, i*_TILE_H
    local color = COLORS.NEUTRAL
    if fov and fov[ti] then
      local visibility = fov[ti][tj]
      if not visibility then
        color = COLORS.BLACK
      elseif visibility == 0 then
        color = COLORS.HALF_VISIBLE
      else
        color = COLORS.NEUTRAL
      end
    end
    g.setColor(color)
    g.draw(_tilemask, x - _TILE_W, y - _TILE_H)
  end
  g.setBlendMode('alpha', 'alphamultiply')
  g.setCanvas()

  return _fovmask
end

function TILEMAP.drawAbyss(g, fov)
  g.push()

  g.origin()
  _FXSHADER:send('mask', _fovmask)
  g.setShader(_FXSHADER)
  g.setColor(COLORS.BACKGROUND)
  g.rectangle('fill', 0, 0, _VIEW_W*_TILE_W, _VIEW_H*_TILE_H)
  g.setShader()

  g.pop()
end

function TILEMAP.drawFloor(g)
  _tile_batch:clear()
  for i, j in CAM:tilesInRange() do
    local ti, tj = i+1, j+1 -- logic coordinates
    local tile = _sector.tiles[ti] and _sector.tiles[ti][tj]
    if tile then
      local tile_type = (tile.type == SCHEMATICS.WALL)
                        and SCHEMATICS.FLOOR or tile.type
      local x, y = j*_TILE_W, i*_TILE_H
      _tile_batch:add(_tile_quads[tile_type], x, y,
                  0, 1, 1, unpack(_tile_offset[tile.type]))
    end
  end

  _FXSHADER:send('mask', _fovmask)
  g.setShader(_FXSHADER)
  g.setColor(COLORS.NEUTRAL)
  g.draw(_tile_batch, 0, 0)
  g.setShader()

  _tile_batch:clear()
end

function TILEMAP.drawWallInLine(g, i, fov)
  -- to be implemented in v11.0
end

return TILEMAP

