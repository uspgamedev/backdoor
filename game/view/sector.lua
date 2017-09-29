
local RES         = require 'resources'
local SCHEMATICS  = require 'domain.definitions.schematics'
local COLORS      = require 'domain.definitions.colors'

local TILE_W = 80
local TILE_H = 80
local HALF_W = 10
local HALF_H = 6

local TEXTURE
local TILE_COLORS
local TILES
local FONT

local Cursor

local SectorView = Class{
  __includes = { ELEMENT }
}

local function _moveCamera(target)
  local x, y = CAM:position()
  local i, j = target:getPos()
  local tx, ty = (j-0.5)*TILE_W, (i-0.5)*TILE_H
  local smooth = 1/12
  CAM:move((tx - x)*smooth,(ty - y)*smooth)
end

local function _initDrawables()

  -- FIXME: Tiles are not gotten from DB right now
  local g = love.graphics

  FONT = RES.loadFont("Text", 24)

  TEXTURE = RES.loadTexture("bare-tiles")
  TEXTURE:setFilter("nearest", "nearest")
  local tw, th = TEXTURE:getDimensions()

  TILE_COLORS = {
    [SCHEMATICS.FLOOR] = g.newQuad(0, 0, TILE_W, TILE_H, tw, th),
    [SCHEMATICS.EXIT] = g.newQuad(80, 0, TILE_W, TILE_H, tw, th),
    shade = g.newQuad(160, 0, TILE_W, TILE_H, tw, th),
  }

  TILES = g.newSpriteBatch(TEXTURE, 512, "stream")

end

function SectorView:init(route)

  ELEMENT.init(self)

  self.target = nil
  self.cursor = nil

  self.route = route
  self.body_sprites = {}

  _initDrawables()

end

function SectorView:lookAt(target)
  self.target = target
end

function SectorView:draw()
  local sector = self.route.getCurrentSector()
  local g = love.graphics
  if self.target then
    _moveCamera(self.target)
  end
  local cx, cy = CAM:position()
  local draw_bodies = {}
  local highlights = {}
  cx = cx / TILE_W
  cy = cy / TILE_H
  g.setBackgroundColor(75, 78, 60, 255)
  g.setColor(COLORS.NEUTRAL)
  TILES:clear()
  for i = 0, sector.h-1 do
    for j = 0, sector.w-1 do
      if j >= cx - HALF_W and j <= cx + HALF_W and
        i >= cy - HALF_H and i <= cy + HALF_H then
        local tile = sector.tiles[i+1][j+1]
        if tile then
          -- Add tiles to spritebatch
          local body = sector.bodies[i+1][j+1]
          local x, y = j*TILE_W, i*TILE_H
          g.push()
          TILES:add(TILE_COLORS[tile.type], x, y)
          TILES:add(TILE_COLORS.shade, x, y+TILE_H)
          g.pop()
          if self.cursor and self.cursor.range_checker(i+1, j+1) then
            table.insert(highlights, {x, y, TILE_W, TILE_H, {100, 200, 200}})
          end
          if self.cursor and self.cursor.validator(i+1, j+1) then
            table.insert(highlights, {x, y, TILE_W, TILE_H, {200, 200, 100}})
          end
          if body then
            table.insert(draw_bodies, {body, x, y})
          end
        end
      end
    end
  end
  g.draw(TILES, 0, 0)
  -- Draw highlights
  for _, highlight in ipairs(highlights) do
    local x,y,w,h,color = unpack(highlight)
    color[4] = 100
    g.setColor(color)
    g.rectangle('fill', x, y, w, h)
  end
  --Draw Cursor, if it exists
  if self.cursor then
    local c_i, c_j = self:getCursorPos()
    local x, y = (c_j-1)*TILE_W, (c_i-1)*TILE_H
    g.push()
    g.translate(x, y)
    if self.cursor.validator(c_i,c_j) then
      g.setColor(250, 250, 250)
    else
      g.setColor(255,0,0)
    end
    local line_w = love.graphics.getLineWidth()
    love.graphics.setLineWidth(4)
    g.rectangle("line", 0, 0, TILE_W, TILE_H)
    love.graphics.setLineWidth(line_w)
    g.pop()
  end
  -- Draw dem bodies
  for _, bodyinfo in ipairs(draw_bodies) do
    local body, x, y = unpack(bodyinfo)
    local id = body:getId()
    local draw_sprite = self.body_sprites[id] if not draw_sprite then
      draw_sprite = RES.loadSprite(body:getAppearance())
      self.body_sprites[id] = draw_sprite
    end
    g.push()
    g.setColor(COLORS.NEUTRAL)
    draw_sprite(x, y)
    g.translate(x, y)
    g.setFont(FONT)
    g.print(body:getHP(), TILE_W/8, 0)
    g.pop()
  end

end

--CURSOR FUNCTIONS

function SectorView:newCursor(i,j,validator,range_checker)
  i, j = i or 1, j or 1
  self.cursor = Cursor(i,j,validator,range_checker)
end

function SectorView:removeCursor()
  self.cursor = nil
end

function SectorView:getCursorPos()
  if not self.cursor then return end

  return self.cursor:getPos()
end

function SectorView:setCursorPos(i,j)
  if not self.cursor then return end

  self.cursor.i = i
  self.cursor.j = j
end

function SectorView:moveCursor(di,dj)
  if not self.cursor then return end

  self.cursor.i = self.cursor.i + di
  self.cursor.j = self.cursor.j + dj
end

function SectorView:lookAtCursor()
  if self.cursor then
    self:lookAt(self.cursor)
  end
end

--CURSOR CLASS--

Cursor = Class{
  __includes = { ELEMENT }
}

function Cursor:init(i, j, validator, range_checker)
  self.i = i
  self.j = j

  self.validator = validator
  self.range_checker = range_checker
end

function Cursor:getPos()
  return self.i, self.j
end

return SectorView

