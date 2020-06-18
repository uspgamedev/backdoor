
-- luacheck: globals love

local RES        = require 'resources'
local CAM        = require 'common.camera'
local SCHEMATICS = require 'domain.definitions.schematics'
local COLORS     = require 'domain.definitions.colors'
local VIEWDEFS   = require 'view.definitions'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _VIEW_W = VIEWDEFS.HALF_W*2 - 2
local _VIEW_H = VIEWDEFS.HALF_H*2 - 2

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
local _tileset
local _variations
local _fovmask
local _tilemask

function TILEMAP.init(sector, tileset)
  local texture = RES.loadTexture(tileset.texture)
  _tile_batch = love.graphics.newSpriteBatch(texture, 512, "stream")
  _tileset = tileset
  _sector = sector
  _fovmask = love.graphics.newCanvas(_VIEW_W * _TILE_W, _VIEW_H * _TILE_H)
  _FXSHADER = _FXSHADER or love.graphics.newShader(_FXCODE)
  if not _tilemask then
    local data = love.image.newImageData(_TILE_W*3, _TILE_H*3)
    data:mapPixel(
      function (x, y)
        y = y*_TILE_W/_TILE_H
        local px = math.max(0.5*_TILE_W, math.min(2.5*_TILE_W, x))
        local py = math.max(0.5*_TILE_W, math.min(2.5*_TILE_W, y))
        local d = math.sqrt((x - px)^2 + (y - py)^2)/_TILE_W * 2
        local c = math.max(0, (1-d^2))
        return c, c, c, 1
      end
    )
    _tilemask = love.graphics.newImage(data)
  end
  _variations = {}
  local rng = love.math.newRandomGenerator(0) -- always same seed
  for i = 1, #_sector.tiles do
    _variations[i] = {}
    for j = 1, #_sector.tiles[i] do
      _variations[i][j] = rng:random()
    end
  end
end

local _SIDES = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }
local function _isBorder(fov, i, j, outside)
  for _, side in ipairs(_SIDES) do
    local ti, tj = i + side[1], j + side[2]
    if fov[ti] and outside(fov[ti][tj]) then
      return true
    end
  end
  return false
end

local function NOT_VISIBLE(v) return not v or v == 0 end
local function UNSEEN(v) return not v end

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
    local color = COLORS.BLACK
    if fov and fov[ti] then
      local visible = fov[ti][tj]
      if visible then
        if visible > 0 then
          if not _isBorder(fov, ti, tj, NOT_VISIBLE) then
            color = COLORS.NEUTRAL
          elseif not _isBorder(fov, ti, tj, UNSEEN) then
            color = COLORS.HALF_VISIBLE
          end
        elseif visible == 0 and not _isBorder(fov, ti, tj, UNSEEN) then
          color = COLORS.HALF_VISIBLE
        end
      end
    end
    g.setColor(color)
    g.draw(_tilemask, x - _TILE_W, y - _TILE_H)
  end
  g.setBlendMode('alpha', 'alphamultiply')
  g.setCanvas()

  return _fovmask
end

function TILEMAP.drawAbyss(g)
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
      local variation = _variations[ti][tj]
      local idx = 1
      for _, threshold in ipairs(_tileset.weights[tile_type]) do
        if variation < threshold then
          break
        else
          idx = math.min(idx + 1, #_tileset.weights[tile_type])
        end
      end
      local quad = _tileset.quads[tile_type][idx]
      local offset = _tileset.offsets[tile_type][idx]
      _tile_batch:add(quad, x, y, 0, 1, 1, unpack(offset))
    end
  end

  _FXSHADER:send('mask', _fovmask)
  g.setShader(_FXSHADER)
  g.setColor(COLORS.NEUTRAL)
  g.draw(_tile_batch, 0, 0)
  g.setShader()

  _tile_batch:clear()
end

function TILEMAP.drawWallInLine(g, i, fov) -- luacheck: no unused
  -- to be implemented in v11.0
end

return TILEMAP
