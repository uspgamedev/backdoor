
-- luacheck: globals love

local vec2    = require 'cpml' .vec2
local Button  = require 'view.controlhints.newhand'
local TEXTURE = require 'view.helpers.texture'
local FONT    = require 'view.helpers.font'
local DEFS    = require 'view.definitions'
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

local _MX = 32
local _MY = 32
local _W_OFFSET = 2
local _H_OFFSET = 1
local _GRADIENT_FILTER = .3
local _BACKGROUND_ALPHA = .1
local _MAX_CARDS = 15

local BufferView = Class{
  __includes = { ELEMENT }
}

function BufferView:init(route)
  ELEMENT.init(self)
  self.route = route

  self.sprite = TEXTURE.get('card-base')
  self.sprite:setFilter("linear", "linear", 1)
  self.clr = {1, 1, 1, 1}
  self.side = 'front'
  self.font = FONT.get("Text", 24)
  self.amount = 0

  -- define later
  self.pos = nil
  self.offset = vec2()
  self.format = nil

  -- hint button
  self.button = Button(-5, -50)

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

function BufferView:changeSide(duration, target_buffer)
  if self.side == 'back' then
    local delta = target_buffer:getPosition() - self:getPosition()
    local r, g, b = self.clr[1], self.clr[2], self.clr[3]
    local t_clr = target_buffer.clr
    local tr, tg, tb = t_clr[1], t_clr[2], t_clr[3]
    self.format = "x %d"
    self:addTimer("changeside", MAIN_TIMER, "tween", duration,
                  self.offset, {x = delta.x, y = delta.y}, "out-cubic",
                  function()
                    self.ormat = "%d x"
                    self.offset = vec2()
                    self:removeTimer("changecolor")
                    self.clr[1], self.clr[2], self.clr[3] = r, g, b
                  end)
    self:addTimer("changecolor", MAIN_TIMER, "during", duration,
                  function(dt)
                    self.clr[1] = self.clr[1] + (tr - r)*dt/duration
                    self.clr[2] = self.clr[2] + (tg - g)*dt/duration
                    self.clr[3] = self.clr[3] + (tb - b)*dt/duration
                  end)
  end
end

function BufferView:calculatePosition()
  local W,H = DEFS.VIEWPORT_DIMENSIONS()
  if self.side == 'front' then
    self.pos = vec2(_MX, H - _MY - self.sprite:getHeight())
    self.format = "x %d"
  elseif self.side == 'back' then
    self.pos = vec2(W - _MX - self.sprite:getWidth(), H - _MY - self.sprite:getHeight())
    self.format = "%d x"
  else
    return error("invalid buffer view side position")
  end
end

function BufferView:getPosition()
  return self.pos+self.offset
end

function BufferView:getTopCardPosition()
  local size = self.amount
  if self.side == 'front' then
    return self.pos + vec2(size * _W_OFFSET, size * _H_OFFSET) + self.offset
  elseif self.side == 'back' then
    return self.pos + vec2(size * -_W_OFFSET, size * _H_OFFSET) + self.offset
  end
end

function BufferView:flashFor(_, _) -- luacheck: no self
  --pass
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
end

function BufferView:draw()
  local g = love.graphics
  local text = self.format:format(self.amount)

  g.push()
  g.translate(self.pos.x, self.pos.y)

  local finish, step
  if self.side == "front" then
    --Draw button ontop of front buffer
    self.button:draw()

    finish, step = math.min(self.amount, _MAX_CARDS) - 1, 1
  elseif self.side == "back" then
    finish, step = -math.min(self.amount, _MAX_CARDS) + 1, -1
  else
    error("Not a valid side for bufferview: "..self.side)
  end

  --Draw buffer "background"
  g.setColor(self.clr[1], self.clr[2], self.clr[3], self.clr[4]*_BACKGROUND_ALPHA)
  self.sprite:draw(0, 0)

  g.translate(self.offset.x, self.offset.y)

  --Draw buffer
  local grd
  for i = 0, finish, step do
    grd = (i == finish) and 1 or _GRADIENT_FILTER
    g.setColor(self.clr[1]*grd, self.clr[2]*grd, self.clr[3]*grd, self.clr[4])
    self.sprite:draw(i*_W_OFFSET, step*i*_H_OFFSET)
  end
  --Draw buffer size
  local card_w, card_h = self.sprite:getWidth(), self.sprite:getHeight()
  local text_w, text_h = self.font:getWidth(text), self.font:getHeight()
  grd = _GRADIENT_FILTER
  self.font:set()
  g.setColor(self.clr[1]*grd, self.clr[2]*grd, self.clr[3]*grd, self.clr[4])
  g.print(text, finish*_W_OFFSET + card_w/2 - text_w/2,
                step*finish*_H_OFFSET + card_h/2 - text_h/2)


  g.pop()
end

return BufferView
