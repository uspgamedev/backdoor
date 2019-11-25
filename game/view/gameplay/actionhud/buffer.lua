
-- luacheck: globals love

local vec2       = require 'cpml' .vec2
local HintButton = require 'view.gameplay.actionhud.controlhints.newhand'
local PPCounter  = require 'view.gameplay.actionhud.ppcounter'
local TEXTURE    = require 'view.helpers.texture'
local FONT       = require 'view.helpers.font'
local DEFS       = require 'view.definitions'
local Class      = require "steaming.extra_libs.hump.class"
local ELEMENT    = require "steaming.classes.primitives.element"

local _MX = 16
local _MY = 16
local _GRADIENT_FILTER = .3
local _BACKGROUND_ALPHA = .1
local _MAX_CARDS = 15

--forward functions declaration
local _calculatePosition

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
  self.fake_amount = nil --Used for shuffle animation and pack cards

  self.card_w_offset = 2
  self.card_h_offset = 1

  -- define later
  self.pos = nil
  self.offset = vec2()
  self.format = nil
  self.ppcounter = nil

  -- hint button
  self.button = nil

end

function BufferView.newFrontBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {.8, .8, .8, 1}
  bufview.side = 'front'
  bufview.button = HintButton(-5, -45)
  bufview.ppcounter = PPCounter()
  _calculatePosition(bufview)
  return bufview
end

function BufferView.newBackBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {1, 0.5, 0.5, 1}
  bufview.side = 'back'
  _calculatePosition(bufview)
  return bufview
end

function BufferView:changeSide(duration, target_buffer, actor)
  if self.side == 'back' then
    self:setDrawTable("HUD_FX")
    self.fake_amount = actor:getBufferSize()
    target_buffer.fake_amount = actor:getBackBufferSize()
    local delta = target_buffer:getPosition() - self:getPosition()
    local r, g, b = self.clr[1], self.clr[2], self.clr[3]
    local t_clr = target_buffer.clr
    local tr, tg, tb = t_clr[1], t_clr[2], t_clr[3]
    self.format = "x %d"
    self:addTimer("changecolor", MAIN_TIMER, "during", duration,
                  function(dt)
                    self.clr[1] = self.clr[1] + (tr - r)*dt/duration
                    self.clr[2] = self.clr[2] + (tg - g)*dt/duration
                    self.clr[3] = self.clr[3] + (tb - b)*dt/duration
                  end)
    self:addTimer("changecardoffset", MAIN_TIMER, "tween", duration,
                  self, {card_w_offset = -2}, "out-cubic")
    self:addTimer("changeside", MAIN_TIMER, "tween", duration,
                  self.offset, {x = delta.x, y = delta.y}, "out-cubic",
                  function()
                    self.format = "%d x"
                    self.offset = vec2()
                    self:removeTimer("changecolor")
                    self.clr[1], self.clr[2], self.clr[3] = r, g, b
                    self.card_w_offset = 2
                    target_buffer.fake_amount = nil
                    self.fake_amount = nil
                    self:setDrawTable("HUD_BG")
                  end)
  end
end

function BufferView:getPosition()
  return self.pos+self.offset
end

function BufferView:getTopCardPosition(index_offset)
  index_offset = index_offset or 0
  local size = self.amount
  if self.side == 'front' then
    return self.pos + vec2((size + index_offset) * self.card_w_offset,
                           (size + index_offset) * self.card_h_offset)
                    + self.offset
  elseif self.side == 'back' then
    return self.pos + vec2((size + index_offset) * -self.card_w_offset,
                           (size + index_offset) * self.card_h_offset)
                    + self.offset
  end
end

function BufferView:update(dt)
  local actor = self.route.getControlledActor()
  if self.side == 'front' then
    self.button:setCost(actor:getBody():getConsumption())
    self.button:update(dt)
    self.ppcounter:setPP(actor:getPP())
    self.ppcounter:update(dt)
    self.amount = actor:getBufferSize()
  elseif self.side == 'back' then
    self.amount = actor:getBackBufferSize()
  end
end

function BufferView:draw()
  local g = love.graphics
  local text = self.format:format(self.fake_amount or self.amount)

  g.push()
  g.translate(self.pos.x, self.pos.y)

  local finish, step
  if self.side == "front" then
    --Draw button above front buffer
    self.button:draw()

    finish, step = math.min(self.fake_amount or self.amount, _MAX_CARDS) - 1, 1
  elseif self.side == "back" then
    finish, step = -math.min(self.fake_amount or self.amount, _MAX_CARDS) + 1, -1
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
    self.sprite:draw(i*self.card_w_offset, step*i*self.card_h_offset)
  end

  local card_w, card_h = self.sprite:getWidth(), self.sprite:getHeight()
  local text_w, text_h = self.font:getWidth(text), self.font:getHeight()

  --Draw pp counter
  if self.side == "front" then
    g.push()
    g.translate(math.max(finish,0)*self.card_w_offset + card_w/2,
                step*finish*self.card_h_offset + card_h/2)
    self.ppcounter:draw()
    g.pop()
  end

  --Draw buffer size
  grd = _GRADIENT_FILTER
  self.font:set()
  g.setColor(self.clr[1]*grd, self.clr[2]*grd, self.clr[3]*grd, self.clr[4])
  g.print(text, finish*self.card_w_offset + card_w/2 - text_w/2,
                step*finish*self.card_h_offset + card_h/2 - text_h/2)

  g.pop()
end

function BufferView:addFakeCard()
  if not self.fake_amount then
    self.fake_amount = self.amount
  end
  self.fake_amount = self.fake_amount + 1
end

function BufferView:resetFakeCards()
  self.fake_amount = nil
end

--local functions
function _calculatePosition(self)
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


return BufferView
