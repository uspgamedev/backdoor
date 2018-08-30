
local FONT       = require 'view.helpers.font'
local CARD       = require 'view.helpers.card'
local CardView   = require 'view.card'
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
local _ACTION_TYPES = {
  'play',
}
local _FOCUS_ICON = {
  -6, 0, 0, -9, 6, 0, 0, 9
}

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
  self.action_type = -1
  self.x, self.y = (3*_WIDTH/4)/2, _HEIGHT - 50
  self.initial_x, self.initial_y = self.x, self.y
  self.route = route
  self.gap_scale = _GAP_SCALE.MIN

  --Emergency effect
  self.emer_fx_alpha = 0
  self.emer_fx_max = math.pi
  self.emer_fx_speed = 3.5
  self.emer_fx_v = math.sin(self.emer_fx_alpha)
  self:reset()

  _font = _font or FONT.get(_F_NAME, _F_SIZE)

end

function HandView:getFocus()
  return self.focus_index
end

function HandView:moveFocus(dir)
  if dir == "LEFT" then
    self.focus_index = (self.focus_index + #self.hand - 1) % (#self.hand+1) + 1
  elseif dir == "RIGHT" then
    self.focus_index = self.focus_index % (#self.hand+1) + 1
  end
end

function HandView:getActionType()
  return _ACTION_TYPES[self.action_type]
end

function HandView:changeActionType(dir)
  if dir == 'UP' then
    self.action_type = (self.action_type - 2) % #_ACTION_TYPES + 1
  elseif dir == 'DOWN' then
    self.action_type = self.action_type % #_ACTION_TYPES + 1
  else
    error(("Unknown dir %s"):format(dir))
  end
end

function HandView:activate()
  self.focus_index = 1
  self.action_type = 1
  self:removeTimer("start", MAIN_TIMER)
  self:removeTimer("end", MAIN_TIMER)
  self:addTimer("start", MAIN_TIMER, "tween", 0.2, self,
                { y = self.initial_y - CARD.getHeight(),
                  gap_scale = _GAP_SCALE.MAX }, 'out-back')
end

function HandView:deactivate()
  self.focus_index = -1
  self.action_type = -1

  self:removeTimer("start", MAIN_TIMER)
  self:removeTimer("end", MAIN_TIMER)

  self:addTimer("end", MAIN_TIMER, "tween", 0.2, self,
                { y = self.initial_y, gap_scale = _GAP_SCALE.MIN },
                'out-back')
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

function HandView:update(dt)
  for _,card in ipairs(self.hand) do
    card:update(dt)
  end
end

function HandView:draw()
  local hand = { unpack(self.hand) }
  local card = CardView('draw')
  table.insert(hand, card)
  local size = #hand
  local gap = _GAP * self.gap_scale
  local step = card:getWidth() + gap
  local x, y = self.x + (size*card:getWidth() + (size-1)*gap)/2, self.y
  local enter = math.abs(y - self.initial_y) / (card:getHeight())
  local boxwidth = 128
  local g = love.graphics

  --update emergency effect
  local dt = love.timer.getDelta()
  self.emer_fx_alpha = self.emer_fx_alpha + self.emer_fx_speed*dt
  self.emer_fx_v = math.sin(self.emer_fx_alpha)
  while self.emer_fx_alpha >= self.emer_fx_max do
    self.emer_fx_alpha = self.emer_fx_alpha - self.emer_fx_max
  end


  -- draw action type
  _font.set()
  local colorname = (self:getActionType() or "BACKGROUND"):upper()
  local poly = {
    -20, _HEIGHT/2,
    self.x + boxwidth, _HEIGHT/2,
    self.x + boxwidth, _HEIGHT/2 + 40,
    self.x + boxwidth - 20, _HEIGHT/2 + 60,
    -20, _HEIGHT/2 + 60,
  }
  local offset = self.x+boxwidth

  -- draw each card
  local infoy = 40
  for i=size,1,-1 do
    local card = hand[i]
    local dx = (size-i+1)*step
    card:setFocus(i == self.focus_index)
    card:setPosition(x - dx + gap,
                     y - 50 + (0.2+enter*0.4)*(i - (size+1)/2)^2*_GAP)
    card:draw()
    if self.focus_index == i then
      local infox = _GAP
      CARD.drawInfo(card.card, infox, infoy, _WIDTH/3 - infox, enter,
                    self.route:getPlayerActor())
    end
  end

  self:drawFocusBar(g, self.route.getControlledActor())
end

function HandView:drawFocusBar(g, actor)
  if not actor then return end
  -- draw hand countdown
  local maxfocus = ACTIONDEFS.FOCUS_DURATION
  local focuscountdown = math.min(actor:getFocus(), maxfocus)
  local current = self.hand_count_down or 0
  local y = 144
  current = current + (focuscountdown - current) * 0.2
  if math.abs(current - focuscountdown) < 1 then
    current = focuscountdown
  end
  self.hand_count_down = current
  local handbar_percent = current / maxfocus
  local emergency_percent = .33
  local handbar_width = 492/2
  local handbar_height = 12
  local handbar_gap = handbar_width / (maxfocus-1) local font = FONT.get("Text", 18)
  local fh = font:getHeight()*font:getLineHeight()
  local mx, my = 60, 20
  local slope = handbar_height + 2*my
  font:set()
  g.push()
  g.origin()
  g.translate(self.x - handbar_width/2, _HEIGHT - handbar_height - my)

  --Drawing background
  g.setColor(_BG)
  g.polygon('fill', -mx, handbar_height+my,
                    -mx + slope, -my,
                    handbar_width + mx - slope, -my,
                    handbar_width + mx, handbar_height + my)
  --Drawing focus bar
  g.setLineWidth(1)
  local red, gre, blu, a = unpack(COLORS.NOTIFICATION)
  if handbar_percent <= emergency_percent then
    red, gre, blu = red + (1-red)*self.emer_fx_v,
                    gre + (1-gre)*self.emer_fx_v,
                    blu + (1-blu)*self.emer_fx_v
  end
  g.push()
  g.translate(0, 0.3*(handbar_height + 2*my))
  for i=0,maxfocus-1 do
    g.push()
    g.translate(i * handbar_gap, 0)
    g.setColor(COLORS.EMPTY)
    g.polygon('fill', _FOCUS_ICON)
    if current >= i then
      g.setColor(red, gre, blu, a * math.min(1, (current-i)))
      g.polygon('fill', _FOCUS_ICON)
    end
    g.pop()
  end
  g.pop()

  --Drawing contour lines
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(2)
  g.line(-mx, handbar_height+my,
         -mx + slope, -my,
         handbar_width + mx - slope, -my,
         handbar_width + mx, handbar_height + my)


  --Draw text
  g.translate(0, -20)
  g.setColor(COLORS.BLACK)
  g.printf("Focus Duration", 0, 0, handbar_width, 'center')
  g.translate(-1, -1)
  g.setColor(COLORS.NEUTRAL)
  g.printf("Focus Duration", 0, 0, handbar_width, 'center')
  g.pop()
end

function HandView:addCard(actor, card)
  if self.route.getControlledActor() == actor then
    local view = CardView(card)
    table.insert(self.hand, view)
    local frontbuffer = Util.findId('frontbuffer_view')
    Transmission(frontbuffer:getPoint(), view):addElement("GUI")
    view:flashFor(0.5)
  end
end

--Remove card given by index (must be valid)
function HandView:removeCard(actor, card_index)
  if self.route.getControlledActor() == actor then
    table.remove(self.hand, card_index)
  end
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
    end
  end

end

return HandView
