
local math = require 'common.math'
local HoldBar = require 'view.helpers.holdbar'
local CARD = require 'view.helpers.card'
local FONT = require 'view.helpers.font'
local COLORS = require 'domain.definitions.colors'

-- MODULE -----------------------------------
local View = Class({
  __includes = ELEMENT
})

-- CONSTS -----------------------------------
local _EMPTY = {}
local _ENTER_TIMER = "manage_card_list_enter"
local _TEXT_TIMER = "manage_card_list_text"
local _CONSUMED_TIMER = "consumed_card:"
local _ENTER_SPEED = .2
local _MOVE_SMOOTH = 1/5
local _EPSILON = 2e-5
local _SIN_INTERVAL = 1/2^5
local _PD = 40
local _ARRSIZE = 20
local _MAX_Y_OFFSET = 768
local _PI = math.pi
local _CONSUME_TEXT = "consume (+1 EXP)"
local _WIDTH, _HEIGHT
local _CW, _CH

-- LOCAL VARS
local _font

-- LOCAL METHODS ----------------------------
local function _initGraphicValues()
  local g = love.graphics
  _WIDTH, _HEIGHT = g.getDimensions()
  _font = FONT.get("TextBold", 21)
  _CW = CARD.getWidth()
  _CH = CARD.getHeight()
end

local function _next_circular(i, len, n)
  if n == 0 then return i end
  return _next_circular(i % len + 1, len, n - 1)
end

local function _prev_circular(i, len, n)
  if n == 0 then return i end
  return _prev_circular((i - 2) % len + 1, len, n - 1)
end

-- PUBLIC METHODS ---------------------------
function View:init(hold_actions)
  ELEMENT.init(self)

  self.enter = 0
  self.text = 0
  self.selection = 1
  self.cursor = 0
  self.y_offset = {}
  self.move = self.selection
  self.offsets = {}
  self.card_list = _EMPTY
  self.consumed = {}
  self.consume_log = false
  self.holdbar = HoldBar(hold_actions)
  self.exp_gained = 0
  self.exp_gained_offset = 0
  self.exp_gained_alpha = 1

  _initGraphicValues()
end

function View:isLocked()
  return self.holdbar:isLocked()
end

function View:open(card_list)
  self.card_list = card_list
  self.consume_log = {}
  self.holdbar:unlock()
  self.selection = math.ceil(#card_list/2)
  for i=1,#card_list do self.y_offset[i] = 0 end
  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                _ENTER_SPEED, self, { enter=1, text=1 }, "out-quad")
end

function View:close()
  self.holdbar:lock()
  self.consume_log = _EMPTY
  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                _ENTER_SPEED, self, { enter=0, text=0, exp_gained_alpha = 0}, "out-quad",
                function ()
                  self.card_list = _EMPTY
                  self:destroy()
                end)
end

function View:collectCards()
  self.holdbar:lock()
  self:addTimer(_TEXT_TIMER, MAIN_TIMER, "tween", _ENTER_SPEED,
                self, {text=0}, "in-quad")
  for i = 1, #self.card_list do
    self:addTimer("collect_card_"..i, MAIN_TIMER, "after",
                  i*3/60 + .05,
                  function()
                    self:addTimer("getting_card_"..i, MAIN_TIMER,
                                  "tween", .3, self.y_offset,
                                  {[i] = _MAX_Y_OFFSET}, "in-back")
                  end)
  end
  self:addTimer("finish_collection", MAIN_TIMER, "after",
                0.65, function() self.card_list = _EMPTY end)
end

function View:selectPrev(n)
  if self:isLocked() then return end
  n = n or 1
  self.selection = _prev_circular(self.selection, #self.card_list, n)
  self.holdbar:reset()
end

function View:selectNext()
  if self:isLocked() then return end
  n = n or 1
  self.selection = _next_circular(self.selection, #self.card_list, n)
  self.holdbar:reset()
end

function View:setSelection(n)
  self.selection = n
end

function View:updateSelection()
  local selection = self.selection
  local card_list_size = #self.card_list
  for i = selection, card_list_size do
    self.offsets[i] = 1
  end
  self.selection = math.min(selection, card_list_size)
end

function View:popSelectedCard()
  local card = table.remove(self.card_list, self.selection)
  table.insert(self.consumed, {
    card = card,
    consumation = 0,
  })
  local index = #self.consumed
  local holdbar = self.holdbar
  holdbar:lock()
  self:addTimer(_CONSUMED_TIMER..index, MAIN_TIMER, "tween",
                _ENTER_SPEED, self.consumed[index], {consumation=1},
                "out-quad", function()
                              holdbar:unlock()
                              table.remove(self.consumed, index)
                            end)

  return self.selection, card
end

function View:isCardListEmpty()
  return #self.card_list == 0
end

function View:consumeCard()
  local idx, card = self:popSelectedCard()
  self:updateSelection()
  self.exp_gained = self.exp_gained + 1
  self.exp_gained_offset = -10
  table.insert(self.consume_log, idx)
end

function View:getConsumeLog()
  return self.consume_log or _EMPTY
end

function View:draw()
  local g = love.graphics
  local enter = self.enter
  g.push()

  if enter > 0 then
    self:drawBG(g, enter)
    self:drawCards(g, enter)
    self:drawConsumed(g, enter)
    self:drawGainedEXP(g)
  end

  g.pop()
end

function View:drawBG(g, enter)
  g.setColor(0, 0, 0, enter*0.5)
  g.rectangle("fill", 0, 0, _WIDTH, _HEIGHT)
end

function View:drawCards(g, enter)
  local selection = self.selection
  local card_list = self.card_list
  local card_list_size = #card_list

  g.push()

  -- smooth enter!
  g.translate(math.round((_WIDTH/2)*(1-enter)+_WIDTH/2-_CW/2),
              math.round(3*_HEIGHT/7-_CH/2))

  -- smooth movement!
  self.move = self.move + (selection - self.move)*_MOVE_SMOOTH
  if (self.move-selection)^2 <= _EPSILON then self.move = selection end
  g.translate(math.round(-(_CW+_PD)*(self.move-1)), 0)

  -- draw each card
  for i = 1, card_list_size do
    g.push()
    local focus = selection == i
    local dist = math.abs(selection-i)
    local offset = self.offsets[i] or 0

    -- smooth offset when consuming cards
    offset = offset > _EPSILON and offset - offset * _MOVE_SMOOTH or 0
    self.offsets[i] = offset
    g.translate((_CW+_PD)*(i-1+offset), 0)
    g.translate(0, self.y_offset[i])
    CARD.draw(card_list[i], 0, 0, focus,
              dist>0 and enter/dist or enter)
    g.pop()
  end
  g.pop()

  -- draw selection
  g.push()
  g.translate(math.round(_WIDTH/2),
              math.round(3*_HEIGHT/7-_CH/2))
  enter = self.text
  if enter > 0 then
    self:drawArrow(g, enter)
    if card_list[selection] then
      self:drawCardDesc(g, card_list[selection], enter)
    end
  end
  g.pop()
end

function View:drawArrow(g, enter)
  local text_width = _font:getWidth(_CONSUME_TEXT)
  local lh = 1.25
  local text_height
  local senoid

  g.push()

  -- move arrow in senoid
  self.cursor = self.cursor + _SIN_INTERVAL
  while self.cursor > 1 do self.cursor = self.cursor - 1 end
  senoid = (_ARRSIZE/2)*math.sin(self.cursor*_PI)

  _font:setLineHeight(lh)
  _font.set()
  text_height = _font:getHeight()*lh

  g.translate(0, -_PD - text_height*2.5)
  self:drawHoldBar(g)

  g.translate(0, text_height*.5)
  g.setColor(1, 1, 1, enter)
  g.printf(_CONSUME_TEXT, -text_width/2, 0, text_width, "center")

  g.translate(-_ARRSIZE/2, _PD + text_height - _ARRSIZE - senoid)
  g.polygon("fill", 0, 0, _ARRSIZE/2, -_ARRSIZE, _ARRSIZE, 0)

  g.pop()
end

function View:drawCardDesc(g, card, enter)
  g.push()
  g.translate(-1.5*_CW, _CH+_PD)
  CARD.drawInfo(card, 0, 0, 4*_CW, enter)
  g.pop()
end

function View:drawConsumed(g, enter)
  local consumed = self.consumed

  g.push()
  g.translate(math.round(_WIDTH/2-_CW/2), math.round(3*_HEIGHT/7-_CH/2))

  for i, info in ipairs(consumed) do
    local consumation = info.consumation
    CARD.draw(info.card, 0, -_CH*info.consumation, false, enter*(1-info.consumation))
  end

  g.pop()
end

function View:drawHoldBar(g)
  if self.holdbar:update() then
    self:consumeCard()
  end
  self.holdbar:draw(0, 0)
end


function View:drawGainedEXP(g)
  local offset_speed = 120
  if self.exp_gained > 0 then
    local font = FONT.get("Text", 24)
    local str = ("+%d"):format(self.exp_gained)
    local x, y = 100, g.getHeight()-100-font:getHeight(str)

    font:set()
    g.setColor(COLORS.DARK[1], COLORS.DARK[2], COLORS.DARK[3], self.exp_gained_alpha)
    g.print(str, x, y - 1 + self.exp_gained_offset)
    g.setColor(COLORS.VALID[1], COLORS.VALID[2], COLORS.VALID[3], self.exp_gained_alpha)
    g.print(str, x, y - 3 + self.exp_gained_offset)

    if self.exp_gained_offset < 0 then
      self.exp_gained_offset = math.min(0, self.exp_gained_offset + offset_speed*love.timer.getDelta())
    end
  end
end


return View
