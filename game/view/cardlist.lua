
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
function View:init()
  ELEMENT.init(self)

  self.enter = 0
  self.text = 0
  self.selection = 1
  self.cursor = 0
  self.move = self.selection
  self.offsets = {}
  self.card_list = _EMPTY

  _initGraphicValues()
end

function View:open(card_list)
  self.card_list = card_list
  self.selection = math.ceil(#card_list/2)
  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                _ENTER_SPEED, self, { enter=1, text=1 }, "out-quad")
end

function View:close()
  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                _ENTER_SPEED, self, { enter=0, text=0 }, "out-quad",
                function ()
                  self.card_list = _EMPTY
                  self:destroy()
                end)
end

function View:selectPrev(n)
  n = n or 1
  self.selection = _prev_circular(self.selection, #self.card_list, n)
end

function View:selectNext()
  n = n or 1
  self.selection = _next_circular(self.selection, #self.card_list, n)
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

function View:isCardListEmpty()
  return #self.card_list == 0
end

function View:draw()
  local g = love.graphics
  local enter = self.enter
  g.push()

  if enter > 0 then
    self:drawBG(g, enter)
    self:drawCards(g, enter)
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
    if card_list[selection] then
      self:drawCardDesc(g, card_list[selection], enter)
    end
  end
  g.pop()
end

function View:drawCardDesc(g, card, enter)
  g.push()
  g.translate(-1.5*_CW, _CH+_PD)
  CARD.drawInfo(card, 0, 0, 4*_CW, enter)
  g.pop()
end

return View

