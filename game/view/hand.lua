
local FONT       = require 'view.helpers.font'
local CARD       = require 'view.helpers.card'
local CardView   = require 'view.card'
local CardInfo   = require 'view.cardinfo'
local COLORS     = require 'domain.definitions.colors'
local ACTIONDEFS = require 'domain.definitions.action'
local Transmission = require 'view.transmission'
local vec2   = require 'cpml' .vec2

local math = require 'common.math'

--CONSTS--
local _WIDTH, _HEIGHT
local _F_NAME = "Title" --Font name
local _F_SIZE = 24 --Font size
local _GAP = 20
local _GAP_SCALE = { MIN = -0.5, MAX = 1 }
local _BG = {12/256, 12/256, 12/256, 1}
local _FOCUS_ICON = {
  -6, 0, 0, -9, 6, 0, 0, 9
}
local _FADE_SPD = 2

local _font

--HandView Class--

local HandView = Class{
  __includes = { ELEMENT }
}

--CLASS FUNCTIONS--

function HandView:init(route)

  ELEMENT.init(self)

  _WIDTH, _HEIGHT = love.graphics.getDimensions()

  self.focus_index = -1 --What card is focused. -1 if none
  self.x, self.y = (3*_WIDTH/4)/2, _HEIGHT - 50
  self.initial_x, self.initial_y = self.x, self.y
  self.route = route
  self.gap_scale = _GAP_SCALE.MIN
  self.cardinfo = CardInfo(route)
  self.alpha = 1
  self.hiding = false
  self.keep_focused_card = false

  self.fxqueue = {}

  self:reset()

  _font = _font or FONT.get(_F_NAME, _F_SIZE)

end

function HandView:isAnimating()
  return #self.fxqueue > 0 or not not self.fx
end

function HandView:getFocus()
  return self.focus_index
end

function HandView:moveFocus(dir)
  if dir == "LEFT" then
    self.focus_index = (self.focus_index - 2) % (#self.hand) + 1
  elseif dir == "RIGHT" then
    self.focus_index = self.focus_index % (#self.hand) + 1
  end
end

function HandView:isActive()
  return self.focus_index > 0
end

function HandView:activate()
  self.focus_index = 1
  self:removeTimer("start", MAIN_TIMER)
  self:removeTimer("end", MAIN_TIMER)
  self:addTimer("start", MAIN_TIMER, "tween", 0.2, self,
                { y = self.initial_y - CARD.getHeight(),
                  gap_scale = _GAP_SCALE.MAX }, 'out-back')
end

function HandView:deactivate()
  self.focus_index = -1

  self:removeTimer("start", MAIN_TIMER)
  self:removeTimer("end", MAIN_TIMER)

  self:addTimer("end", MAIN_TIMER, "tween", 0.2, self,
                { y = self.initial_y, gap_scale = _GAP_SCALE.MIN },
                'out-back')
end

function HandView:keepFocusedCard(flag)
  self.keep_focused_card = flag
end

function HandView:positionForIndex(i)
  local size = #self.hand + 1
  local card = self.hand[i]
  local gap = _GAP * self.gap_scale
  local step = card:getWidth() + gap
  local x, y = self.x + (size*card:getWidth() + (size-1)*gap)/2,
               self.y
  local enter = math.abs(y - self.initial_y) / (card:getHeight())
  local dx = (size-i+1)*step
  return x - dx + gap,
         y - 50 + (0.2+enter*0.4)*(i - (size+1)/2)^2*_GAP
end

function HandView:hide()
  self.hiding = true
end

function HandView:show()
  self.hiding = false
end

function HandView:update(dt)
  for _,card in ipairs(self.hand) do
    card:update(dt)
  end
  self.cardinfo:update(dt)
  if not self.hiding or #self.fxqueue > 0 then
    self.alpha = self.alpha + (1 - self.alpha) * dt * _FADE_SPD * 4
  else
    if self.alpha > 0.10 then
      self.alpha = self.alpha + (0 - self.alpha) * dt * _FADE_SPD
    else
      self.alpha = 0
    end
  end
  if #self.fxqueue > 0 and not self.fx then
    self.fx = table.remove(self.fxqueue, 1)
    self:fx()
  end
end

function HandView:draw()
  local hand = self.hand
  local size = #hand
  if size <= 0 then return end
  local card = hand[1]
  local gap = _GAP * self.gap_scale
  local step = card:getWidth() + gap
  local x, y = self.x + (size*card:getWidth() + (size-1)*gap)/2, self.y
  local enter = math.abs(y - self.initial_y) / (card:getHeight())
  local boxwidth = 128
  local g = love.graphics


  -- draw action type
  _font.set()
  local colorname = "BACKGROUND"
  local poly = {
    -20, _HEIGHT/2,
    self.x + boxwidth, _HEIGHT/2,
    self.x + boxwidth, _HEIGHT/2 + 40,
    self.x + boxwidth - 20, _HEIGHT/2 + 60,
    -20, _HEIGHT/2 + 60,
  }
  local offset = self.x+boxwidth

  -- draw each card
  for i=size,1,-1 do
    local card = hand[i]
    local dx = (size-i+1)*step
    card:setFocus(i == self.focus_index)
    if DRAW_TABLE['HUD_FX'][card]
       or (self.keep_focused_card and i == self.focus_index) then
      card:setAlpha(1)
    else
      card:setAlpha(self.alpha)
    end
    card:setPosition(x - dx + gap,
                     y - 50 + (0.2+enter*0.4)*(i - (size+1)/2)^2*_GAP)
    card:draw()
  end
  if self.cardinfo:isVisible() then
    local i = self.focus_index
    local card = hand[i]
    if not card then return end
    self.cardinfo:anchorTo(card, i <= #hand/2 and 'right' or 'left')
    self.cardinfo:setCard(card.card)
    self.cardinfo:draw()
  end
end

function HandView:doAddCard(actor, card)
  MAIN_TIMER:script(function(wait)
    if self.route.getControlledActor() == actor then
      local view = CardView(card)
      table.insert(self.hand, view)
      local frontbuffer = Util.findId('frontbuffer_view')
      Transmission(frontbuffer, view, COLORS.FLASH_DRAW):addElement("HUD_FX")
      frontbuffer:flashFor(0.5, COLORS.FLASH_DRAW)
      view:flashFor(0.5, COLORS.FLASH_DRAW)
      wait(0.1)
      self.fx = false
    end
  end)
end

function HandView:doRemoveCard(actor, card_index, discarded)
  MAIN_TIMER:script(function(wait)
    if self.route.getControlledActor() == actor then
      local view = self.hand[card_index]
      if discarded then
        local backbuffer = Util.findId('backbuffer_view')
        Transmission(view, backbuffer, COLORS.FLASH_DISCARD, 0.2)
          :addElement("HUD_FX")
        backbuffer:flashFor(0.2, COLORS.FLASH_DISCARD)
        view:flashFor(0.2, COLORS.FLASH_DISCARD)
        wait(0.2)
      end
      table.remove(self.hand, card_index)
      self.fx = false
    end
  end)
end

function HandView:addCard(actor, card)
  table.insert(self.fxqueue, function () self:doAddCard(actor, card) end)
end

--Remove card given by index (must be valid)
function HandView:removeCard(actor, card_index, discarded)
  table.insert(self.fxqueue, function ()
    self:doRemoveCard(actor, card_index, discarded)
  end)
end

function HandView:reset()

  local controlled_actor = self.route.getControlledActor()

  local cache = {}
  for _,view in ipairs(self.hand or {}) do
    cache[view.card:getId()] = view
  end
  self.hand = {}
  if controlled_actor then
    for i,card in ipairs(controlled_actor:getHand()) do
      self.hand[i] = cache[card:getId()] or CardView(card)
      cache[card:getId()] = nil
    end
  end

  for _,view in pairs(cache) do
    view:setFocus(false)
  end

end

return HandView
