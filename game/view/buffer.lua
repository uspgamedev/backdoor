local vec2    = require 'cpml' .vec2
local Button  = require 'view.controlhints.newhand'
local TEXTURE = require 'view.helpers.texture'
local FONT    = require 'view.helpers.font'
local DEFS    = require 'view.definitions'
local COLORS  = require 'domain.definitions.colors'
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

local _SCALE = 0.75
local _MX = 48
local _MY = 32
local _FLASH_SPD = 20

local BufferView = Class{
  __includes = { ELEMENT }
}

function BufferView:init(route)
  ELEMENT.init(self)
  self.sprite = TEXTURE.get('card-base')
  self.sprite:setFilter("linear", "linear", 1)
  self.clr = {1, 1, 1, 1}
  self.side = 'front'
  self.font = FONT.get("Text", 24)
  self.amount = 0
  self.route = route

  -- define later
  self.pos = nil
  self.offset = nil
  self.align = nil
  self.format = nil
  self.textoffx = nil

  self.button = Button(-5, -115)

  -- Flash FX
  self.flash = 0
  self.add = 0
  self.flashcolor = COLORS.NEUTRAL
end

function BufferView.newFrontBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {.8, .8, .8, 1}
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
    self.button:setCost(actor:getBody():getConsumption())
    self.button:update(dt)
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
      self.button:draw()
  end

  --Draw buffer
  self.font:set()
  local size
  if     self.side == "front" then
    size = self.route:getControlledActor():getBufferSize()
  elseif self.side == "back" then
    size = self.route:getControlledActor():getBackBufferSize()
  else
    error ("Not a valid side for buffer view: "..self.side)
  end
  local offset_x = 2
  local offset_y = -1
  for i = 0, size-1 do
    local grd = i == (size - 1) and 1 or .3
    g.setColor(self.clr[1]*grd, self.clr[2]*grd, self.clr[3]*grd, self.clr[4])

    self.sprite:draw(0 + i*offset_x, 0 - i*offset_y, 0, _SCALE, _SCALE, self.offset.x, self.offset.y)
  end
  g.setColor(self.clr)
  g.printf(text, 0, 0, limit, self.align, 0, nil, nil,
           self.textoffx * limit, self.font:getHeight())

  g.pop()
end

return BufferView
