
local vec2    = require 'cpml' .vec2
local TEXTURE = require 'view.helpers.texture'
local FONT    = require 'view.helpers.font'
local DEFS    = require 'view.definitions'
local COLORS  = require 'domain.definitions.colors'
local RES     = require 'resources'

local _SCALE = 0.3
local _MX = 48
local _MY = 32
local _FLASH_SPD = 20

local BufferView = Class{
  __includes = { ELEMENT }
}

function BufferView:init(route)
  ELEMENT.init(self)
  self.sprite = TEXTURE.get('buffer')
  self.flashsprite = TEXTURE.get('buffer-flat')
  self.sprite:setFilter("linear", "linear", 1)
  self.clr = {1, 1, 1, 1}
  self.side = 'front'
  self.button = RES.loadTexture("button-draw_hand")
  self.button:setFilter("linear")
  self.font = FONT.get("Text", 24)
  self.text_font = FONT.get("Text", 20)
  self.text_font2 = FONT.get("Text", 16)
  self.amount = 0
  self.route = route

  -- define later
  self.pos = nil
  self.offset = nil
  self.align = nil
  self.format = nil
  self.textoffx = nil

  -- Flash FX
  self.flash = 0
  self.add = 0
  self.flashcolor = COLORS.NEUTRAL
end

function BufferView.newFrontBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {1, 1, 1, 1}
  bufview.side = 'front'
  bufview:calculatePosition()
  return bufview
end

function BufferView.newBackBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {1, 0.5, 0.5, 1}
  bufview.side = 'back'
  bufview:calculatePosition()
  return bufview
end

function BufferView:calculatePosition()
  local W,H = DEFS.VIEWPORT_DIMENSIONS()
  if self.side == 'front' then
    self.pos = vec2(_MX, H - _MY)
    self.offset = vec2(0, self.sprite:getHeight())
    self.format = "x %d"
    self.align = 'right'
    self.textoffx = 0
  elseif self.side == 'back' then
    self.pos = vec2(W - _MX, H - _MY)
    self.offset = vec2(self.sprite:getDimensions())
    self.format = "%d x"
    self.align = 'left'
    self.textoffx = 1
  else
    return error("invalid buffer view side position")
  end
end

function BufferView:getPoint()
  if self.side == 'front' then
    return self.pos + vec2(self.sprite:getWidth(), -self.offset.y)/2*_SCALE
  elseif self.side == 'back' then
    return self.pos + vec2(-self.sprite:getWidth(), -self.offset.y)/2*_SCALE
  end
end

function BufferView:flashFor(duration, color)
  self.flash = duration
  self.flashcolor = color or COLORS.NEUTRAL
end

function BufferView:update(dt)
  local actor = self.route.getControlledActor()
  if self.side == 'front' then
    self.amount = actor:getBufferSize()
  elseif self.side == 'back' then
    self.amount = actor:getBackBufferSize()
  end

  if self.flash > 0 then
    self.flash = math.max(0, self.flash - dt)
    if self.add < 0.95 then
      self.add = self.add + (1 - self.add) * dt * _FLASH_SPD
    else
      self.add = 1
    end
  else
    if self.add > 0.05 then
      self.add = self.add - self.add * dt * _FLASH_SPD
    else
      self.add = 0
    end
  end
end

function BufferView:draw()
  local g = love.graphics
  local text = self.format:format(self.amount)
  local limit = self.sprite:getWidth() * _SCALE + self.font:getWidth(text)
              + _MX/3
  g.push()
  g.translate(self.pos.x, self.pos.y)

  --Draw button ontop of front buffer
  if self.side == "front" then
     local scale = .4
     local b_y = -110
     local b_x = -20
     g.setColor(1,1,1)
     g.draw(self.button, b_x, b_y, nil, scale)
     --Draw "draw hand" text
     local text = "draw a new hand"
     local gap = 10
     local text_y = b_y - 5
     local text_x = b_x + self.button:getWidth()*scale + gap
     g.setColor(self.clr)
     self.text_font:set()
     g.print(text, text_x, text_y)
     --Draw cost of consumption
     text_y = text_y + 22
     g.setColor(self.clr)
     self.text_font2:set()
     local cost = self.route:getControlledActor():getBody():getConsumption()
     local text = "-"..cost.." PP"
     g.print(text, text_x, text_y)
  end

  --Draw buffer
  self.font:set()
  g.scale(_SCALE, _SCALE)
  g.setColor(self.clr)
  self.sprite:draw(0, 0, 0, 1, 1, self.offset.x, self.offset.y)
  g.printf(text, 0, 0, limit, self.align, 0, 1/_SCALE, 1/_SCALE,
           self.textoffx * limit, self.font:getHeight())

  if self.add > 0 then
    local cr, cg, cb = self.flashcolor:unpack()
    g.setColor(cr, cg, cb, self.add)
    self.flashsprite:draw(0, 0, 0, 1, 1, self.offset.x, self.offset.y)
  end
  g.pop()
end

return BufferView
