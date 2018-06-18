
local FONT       = require 'view.helpers.font'
local CARD       = require 'view.helpers.card'
local EXP        = require 'view.helpers.exp'
local COLORS     = require 'domain.definitions.colors'
local ACTIONDEFS = require 'domain.definitions.action'

local math = require 'common.math'

--LOCAL FUNCTIONS DECLARATIONS--

local _drawCard

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

function HandView:draw()
  local hand = { unpack(self.hand) }
  table.insert(hand, "draw")
  local size = #hand
  local gap = _GAP * self.gap_scale
  local step = CARD.getWidth() + gap
  local x, y = self.x + (size*CARD.getWidth() + (size-1)*gap)/2, self.y
  local enter = math.abs(y - self.initial_y) / (CARD.getHeight())
  local boxwidth = 128
  local g = love.graphics

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
    CARD.draw(card, x - dx + gap,
              y - 50 + (0.2+enter*0.4)*(i - (size+1)/2)^2*_GAP,
              i == self.focus_index)
    if self.focus_index == i then
      local infox = _GAP
      CARD.drawInfo(card, infox, infoy, _WIDTH/3 - infox, enter, self.route:getPlayerActor())
      if card ~= 'draw' then
        EXP.drawNeededEXP(g, card)
      end
    end
  end

  self:drawHandCountDown(g, self.route.getControlledActor())
end

function HandView:drawHandCountDown(g, actor)
  if not actor then return end
  -- draw hand countdown
  local handcountdown = actor:getHandCountdown()
  local current = self.hand_count_down or 0
  local y = 144
  current = current + (handcountdown - current) * 0.2
  if math.abs(current - handcountdown) < 1 then
    current = handcountdown
  end
  self.hand_count_down = current
  local handbar_percent = current / ACTIONDEFS.HAND_DURATION
  local handbar_width = 492/2
  local handbar_height = 12
  local font = FONT.get("Text", 18)
  local fh = font:getHeight()*font:getLineHeight()
  local mx, my = 60, 20
  local slope = handbar_height + 2*my
  font:set()
  g.push()
  g.origin()
  g.translate(self.x - handbar_width/2, _HEIGHT - handbar_height - my)
  g.setColor(_BG)
  g.polygon('fill', -mx, handbar_height+my,
                    -mx + slope, -my,
                    handbar_width + mx - slope, -my,
                    handbar_width + mx, handbar_height + my)
  g.setLineWidth(1)
  g.setColor(COLORS.EMPTY)
  g.rectangle('fill', 0, 0, handbar_width, handbar_height)
  g.setColor(COLORS.NOTIFICATION)
  g.rectangle('fill', 0, 0, handbar_width * handbar_percent, handbar_height)
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(2)
  g.line(-mx, handbar_height+my,
         -mx + slope, -my,
         handbar_width + mx - slope, -my,
         handbar_width + mx, handbar_height + my)
  local c = 8
  --g.line(-mx+c, handbar_height+my,
    --     -mx + slope, -my+c,
      --   handbar_width + mx - slope, -my+c,
       --  handbar_width + mx-c, handbar_height + my)
  g.translate(0, -14)
  g.setColor(COLORS.BLACK)
  g.printf("Focus Duration", 0, 0, handbar_width, 'center')
  g.translate(-1, -1)
  g.setColor(COLORS.NEUTRAL)
  g.printf("Focus Duration", 0, 0, handbar_width, 'center')
  g.pop()
end

function HandView:addCard(actor, card)
  if self.route.getControlledActor() == actor then
    table.insert(self.hand, card)
  end
end

--Remove card given by index (must be valid)
function HandView:removeCard(actor, card_index)
  if self.route.getControlledActor() == actor then
    table.remove(self.hand, card_index)
  end
end

function HandView:reset()
  self.hand = {}

  local controlled_actor = self.route.getControlledActor()
  if controlled_actor then
    for i,card in ipairs(controlled_actor:getHand()) do
      self.hand[i] = card
    end
  end

end

return HandView
