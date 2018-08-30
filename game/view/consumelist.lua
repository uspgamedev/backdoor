
local math = require 'common.math'
local HoldBar = require 'view.helpers.holdbar'
local CARD = require 'view.helpers.card'
local FONT = require 'view.helpers.font'
local COLORS = require 'domain.definitions.colors'
local DEFS = require 'domain.definitions'
local CardView = require 'view.card'

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
local _PI = math.pi
local _CONSUME_TEXT = "consume (+%d EXP)"
local _FULL_WIDTH, _WIDTH, _HEIGHT
local _LIST_VALIGN
local _CW, _CH

-- LOCAL VARS
local _font
local _otherfont

-- LOCAL METHODS ----------------------------
local function _initGraphicValues()
  local g = love.graphics
  _FULL_WIDTH, _HEIGHT = g.getDimensions()
  _WIDTH = _FULL_WIDTH*3/4
  _LIST_VALIGN = 0.5*_HEIGHT
  _font = FONT.get("TextBold", 20)
  _otherfont = FONT.get("Text", 20)
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
  self.buffered_offset = {}
  self.consumed_offset = {}
  self.card_alpha = {}
  self.move = self.selection
  self.offsets = {}
  self.card_list = _EMPTY
  self.consumed = {}
  self.consumed_count = 0
  self.consume_log = false
  self.holdbar = HoldBar(hold_actions)
  self.exp_gained = 0
  self.exp_gained_offset = 0
  self.exp_gained_alpha = 1
  self.ready_to_leave = false
  self.is_leaving = false

  _initGraphicValues()
end

function View:isLocked()
  return self.holdbar:isLocked()
end

function View:open(card_list, maxconsume)
  self.card_list = {}
  for i,card in ipairs(card_list) do
    self.card_list[i] = CardView(card)
    self.card_list[i]:setAlpha(0.9)
  end
  self.consume_log = {}
  self.holdbar:unlock()
  self.selection = math.ceil(#card_list/2)
  self.maxconsume = maxconsume
  for i=1,#card_list do
    self.buffered_offset[i] = 0
    self.consumed_offset[i] = 0
    self.card_alpha[i] = 1
    self.consumed[i] = false
  end
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

function View:startLeaving()
  self.holdbar:lock()
  self.is_leaving = true
  self:addTimer(_TEXT_TIMER, MAIN_TIMER, "tween", _ENTER_SPEED,
                self, {text=0}, "in-quad")
  for i = 1, #self.card_list do
    self:addTimer("collect_card_"..i, MAIN_TIMER, "after",
                  i*3/60 + .05,
                  function()
                    if not self.consumed[i] then
                      self:addTimer("getting_card_"..i, MAIN_TIMER,
                                    "tween", .3, self.buffered_offset,
                                    {[i] = _HEIGHT}, "in-back")
                    else
                      self:addTimer("consuming_card_off"..i, MAIN_TIMER,
                                    "tween", .3, self.consumed_offset,
                                    {[i] = 30}, "in-quad")
                      self:addTimer("consuming_card_alpha"..i, MAIN_TIMER,
                                    "tween", .3, self.card_alpha,
                                    {[i] = 0}, "in-quad")
                    end
                  end)
  end
  self:addTimer("finish_collection", MAIN_TIMER, "after",
                0.65, function() self.ready_to_leave = true end)

end

function View:isReadyToLeave()
  return self.ready_to_leave
end

function View:toggleSelected()
  local changed = false
  if self.consumed[self.selection] then
    changed = true
    self:removeConsume()
  elseif not self.maxconsume or self.consumed_count < self.maxconsume then
    changed = true
    self:addConsume()
  end
  if changed then
    self.consumed[self.selection] = not self.consumed[self.selection]
  end
end

function View:getConsumeLog()
  local t = {}
  for i, consumed in ipairs(self.consumed) do
    if consumed then
      table.insert(t,i)
    end
  end
  return t
end

function View:addConsume()
  self.exp_gained = self.exp_gained + 1
  self.exp_gained_offset = -10
  self.consumed_count = self.consumed_count + 1
end

function View:removeConsume()
  self.exp_gained = self.exp_gained - 1
  self.exp_gained_offset = -10
  self.consumed_count = self.consumed_count - 1
end

function View:update(dt)
  for _,card in ipairs(self.card_list ) do
    card:update(dt)
  end
end

function View:draw()
  local g = love.graphics
  local enter = self.enter
  g.push()

  if enter > 0 then
    self:drawBG(g, enter)
    self:drawCards(g, enter)
    self:drawGainedEXP(g, enter)
  end

  g.pop()
end

function View:drawBG(g, enter)
  g.setColor(0, 0, 0, enter*0.5)
  g.rectangle("fill", 0, 0, _FULL_WIDTH, _HEIGHT)
end

function View:drawCards(g, enter)
  local selection = self.selection
  local card_list = self.card_list
  local card_list_size = #card_list

  g.push()

  -- smooth enter!
  g.translate(math.round((_WIDTH/2)*(1-enter)+_WIDTH/2-_CW/2),
              math.round(2*_HEIGHT/7-_CH/2))

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
    local consumed = self.consumed[i] and _LIST_VALIGN or 0

    -- smooth offset when consuming cards
    offset = offset > _EPSILON and offset - offset * _MOVE_SMOOTH or 0
    self.offsets[i] = offset
    g.translate((_CW+_PD)*(i-1+offset), _LIST_VALIGN - consumed)
    g.translate(0, self.buffered_offset[i] + -self.consumed_offset[i])
    local card = card_list[i]
    card:setFocus(focus and not self.is_leaving)
    card:setAlpha(dist > 0 and enter/dist*self.card_alpha[i]
                            or enter*self.card_alpha[i])
    card:draw()
    g.pop()
  end
  g.pop()

  -- draw selection
  g.push()
  g.translate(math.round(_WIDTH/2),
              math.round(_HEIGHT/2))
  enter = self.text
  if enter > 0 then
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

  g.translate(0, -text_height*.5)
  g.setColor(1, 1, 1, enter)
  self:drawHoldBar(g)

  g.pop()
end

function View:drawCardDesc(g, card, enter)
  g.push()

  g.setLineWidth(2)
  local maxw = 2*_CW
  g.setColor(COLORS.NEUTRAL)
  g.line(-0.45*_WIDTH, 0, -maxw - _PD, 0)
  g.line(maxw + _PD, 0, 0.45*_WIDTH, 0)
  _otherfont.set()
  g.print("Keep", maxw + _PD, 0.5 * _otherfont:getHeight())
  local consume, extra = "Consume\n", 0
  if self.maxconsume then
    consume = ("Consume [%d/%d]\n"):format(self.consumed_count, self.maxconsume)
    extra = _CW/2 + 10
  end
  local cor, arc, ani = card.card:getOwner():trainingDitribution()
  local cor_t = ("COR %.1f%%  "):format(cor*100)
  local arc_t = ("ARC %.1f%%  "):format(arc*100)
  local ani_t = ("ANI %.1f%%"):format(ani*100)
  local table = {COLORS.NEUTRAL,consume,
           COLORS.COR, cor_t,
           COLORS.ARC, arc_t,
           COLORS.ANI, ani_t
          }
  g.print(table, maxw + _PD, -2.5 * _otherfont:getHeight())

  g.push()
  g.translate(maxw + _PD + 1.5*_CW + extra, -1.6 * _otherfont:getHeight())
  self:drawArrow(g, enter)
  g.pop()

  g.push()
  g.translate(-maxw, -CARD.getInfoHeight(3)/2)
  CARD.drawInfo(card.card, 0, 0, 2*maxw, enter, nil, true)
  g.pop()

  g.pop()
end


function View:drawHoldBar(g)
  if self.holdbar:update() then
    self:startLeaving()
  end
  self.holdbar:draw(0, 0)
end


function View:drawGainedEXP(g, enter)
  local offset_speed = 120
  if self.exp_gained > 0 then
    local str = ("+%4d"):format(self.exp_gained * DEFS.CONSUME_EXP)
    local x, y = 3/4*g.getWidth()+98, g.getHeight()/2 - _otherfont:getHeight()/2

    _otherfont:set()
    g.setColor(COLORS.DARK[1], COLORS.DARK[2], COLORS.DARK[3], enter)
    g.print(str, x, y - 1 + self.exp_gained_offset)
    g.setColor(COLORS.VALID[1], COLORS.VALID[2], COLORS.VALID[3], enter)
    g.print(str, x, y - 3 + self.exp_gained_offset)

    if self.exp_gained_offset < 0 then
      self.exp_gained_offset = math.min(0, self.exp_gained_offset +
                                           offset_speed*love.timer.getDelta())
    end
  end
end


return View
