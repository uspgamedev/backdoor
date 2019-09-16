
-- luacheck: globals love MAIN_TIMER DRAW_TABLE

local DEFS         = require 'domain.definitions'
local COLORS       = require 'domain.definitions.colors'
local FONT         = require 'view.helpers.font'
local CARD         = require 'view.helpers.card'
local CardView     = require 'view.card'
local CardInfo     = require 'view.gameplay.actionhud.hand.cardinfo'
local Button       = require 'view.controlhints.changehandcursor'
local VIEWDEFS     = require 'view.definitions'
local Class        = require "steaming.extra_libs.hump.class"
local ELEMENT      = require "steaming.classes.primitives.element"

local math = require 'common.math'

--CONSTS--
local _WIDTH, _HEIGHT
local _F_NAME = "Title" --Font name
local _F_SIZE = 24 --Font size
local _GAP = 20
local _GAP_SCALE = { MIN = -0.5, MAX = 1 }
local _FADE_SPD = 2
local _BACKPANEL_MARGIN = 20
local _BACKPANEL_WIDTH = 512
local _BACKPANEL_HEIGHT = 64
local _BACKPANEL_VTX = {
  -_BACKPANEL_WIDTH / 2, 0,
  -_BACKPANEL_WIDTH / 2 + _BACKPANEL_MARGIN, -_BACKPANEL_HEIGHT / 2,
  _BACKPANEL_WIDTH / 2 - _BACKPANEL_MARGIN, -_BACKPANEL_HEIGHT / 2,
  _BACKPANEL_WIDTH / 2, 0,
  _BACKPANEL_WIDTH / 2 - _BACKPANEL_MARGIN, _BACKPANEL_HEIGHT / 2,
  -_BACKPANEL_WIDTH / 2 + _BACKPANEL_MARGIN, _BACKPANEL_HEIGHT / 2,
}

local _font

--HandView Class--

local HandView = Class{
  __includes = { ELEMENT }
}

--CLASS FUNCTIONS--

function HandView:init(route)

  ELEMENT.init(self)

  _WIDTH, _HEIGHT = VIEWDEFS.VIEWPORT_DIMENSIONS()

  self.prev_cursor = Button("left")
  self.next_cursor = Button("right")

  self.active = false
  self.focus_index = -1 --What card is focused. -1 if none
  self.x, self.y = _WIDTH/2, _HEIGHT
  self.initial_x, self.initial_y = self.x, self.y
  self.route = route
  self.gap_scale = _GAP_SCALE.MIN
  self.cardinfo = CardInfo(route)
  self.alpha = 1
  self.hiding = false
  self.keep_focused_card = false

  self:reset()

  _font = _font or FONT.get(_F_NAME, _F_SIZE)

end

function HandView:getFocus()
  return self.focus_index
end

function HandView:moveFocus(dir)
  if dir == "RIGHT" then
    self.focus_index = (self.focus_index - 2) % (#self.hand) + 1
  elseif dir == "LEFT" then
    self.focus_index = self.focus_index % (#self.hand) + 1
  end
end

function HandView:isActive()
  return self.active
end

function HandView:activate()
  self.active = true
  self.focus_index = DEFS.HAND_LIMIT
  self:removeTimer("start", MAIN_TIMER)
  self:removeTimer("end", MAIN_TIMER)
  self:addTimer("start", MAIN_TIMER, "tween", 0.2, self,
                { y = self.initial_y - CARD.getHeight(),
                  gap_scale = _GAP_SCALE.MAX }, 'out-back')
end

function HandView:deactivate()
  self.active = false

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
  local size = #self.hand
  i = size + 1 - i
  local gap = _GAP * self.gap_scale
  local step = VIEWDEFS.CARD_W + gap
  local width = size*VIEWDEFS.CARD_W + (size-1)*gap
  local x, y = self.x - width/2, self.y
  local enter = math.abs(y - self.initial_y) / VIEWDEFS.CARD_H
  local dx = (i-1)*step
  return x + dx, y - 50 + (0.2+enter*0.4)*_GAP
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
  if not self.hiding then
    self.alpha = self.alpha + (1 - self.alpha) * dt * _FADE_SPD * 4
  else
    if self.alpha > 0.01 then
      self.alpha = self.alpha + (0 - self.alpha) * dt * _FADE_SPD
    else
      self.alpha = 0
    end
  end
  self.prev_cursor:update(dt)
  self.next_cursor:update(dt)
end

function HandView:draw()
  local hand = self.hand
  local size = #hand
  if size <= 0 then return end
  local gap = _GAP * self.gap_scale
  local width = (size*VIEWDEFS.CARD_W + (size-1)*gap)
  local x, y = self.x - width/2, self.y
  local enter = math.abs(y - self.initial_y) / VIEWDEFS.CARD_H
  local g = love.graphics


  -- draw action type
  _font.set()

  -- draw buttons
  local button_y = y + 20 + (0.2+enter*0.4)*(1 - (size+1)/2)^2*_GAP
  local button_x = x - self.prev_cursor:getWidth()
  self.prev_cursor:setPos(button_x, button_y)
  self.prev_cursor:draw()
  button_x = x + width
  self.next_cursor:setPos(button_x, button_y)
  self.next_cursor:draw()

  -- draw back panel
  g.setColor(COLORS.DARK)
  g.push()
  g.translate(x + width / 2, y + _BACKPANEL_HEIGHT / 2)
  g.polygon('fill', _BACKPANEL_VTX)
  g.pop()

  -- draw each card
  for i=1,size do
    local card = hand[i]
    card:setFocus(i == self.focus_index)
    if DRAW_TABLE['HUD_FX'][card]
       or (self.keep_focused_card and i == self.focus_index) then
      card:setAlpha(1)
    else
      card:setAlpha(self.alpha)
    end
    card:setPosition(self:positionForIndex(i))
  end
  if self.cardinfo:isVisible() then
    local i = self.focus_index
    local card = hand[i]
    if not card then return end
    self.cardinfo:setCard(card.card)
    self.cardinfo:draw()
  end
end

function HandView:addCard(card_view)
  table.insert(self.hand, card_view)
end

--Remove card given by index (must be valid)
function HandView:removeCard( card_index)
  table.remove(self.hand, card_index):kill()
end

function HandView:cardCount()
  return #self.hand
end

function HandView:getFocusedCard()
  return self.hand[self.focus_index]
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
