
local math = require 'common.math'
local CARD = require 'view.helpers.card'
local FONT = require 'view.helpers.font'

-- MODULE -----------------------------------
local View = Class({
  __includes = ELEMENT
})

-- CONSTS -----------------------------------
local _ENTER_TIMER = "manage_buffer_enter"
local _ENTER_SPEED = .2
local _MOVE_SMOOTH = 1/5
local _EPSILON = 2e-5
local _SIN_INTERVAL = 1/2^5
local _PD = 40
local _ARRSIZE = 20
local _PI = math.pi
local _CONSUME_TEXT = "consume"

-- LOCAL VARS
local _width, _height
local _cw, _ch
local _font

-- LOCAL METHODS ----------------------------
local function _initGraphicValues()
  local g = love.graphics
  _width, _height = g.getDimensions()
  _font = FONT.get("TextBold", 21)
  _cw = CARD.getWidth()
  _ch = CARD.getHeight()
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
function View:init(actor)
  ELEMENT.init(self)

  self.enter = 0
  self.selection = 1
  self.cursor = 0
  self.move = self.selection
  self.offsets = {}
  self.actor = actor
  self.backbuffer = false

  _initGraphicValues()
end

function View:open(backbuffer)
  self.selection = 1
  self.backbuffer = backbuffer
  self.invisible = false
  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                _ENTER_SPEED, self, { enter = 1 }, "out-quad")
end

function View:close()
  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                _ENTER_SPEED, self, { enter = 0 }, "out-quad",
                function ()
                  self.invisible = true
                  self.backbuffer = false
                end)
end

function View:selectPrev()
  self.selection = _prev_circular(self.selection, #self.backbuffer, 1)
end

function View:selectNext()
  self.selection = _next_circular(self.selection, #self.backbuffer, 1)
end

function View:setSelection(n)
  self.selection = n
end

function View:updateSelection()
  local selection = self.selection
  local buffer_size = #self.backbuffer
  for i = selection, buffer_size do
    self.offsets[i] = 1
  end
  self.selection = math.min(selection, buffer_size)
end

function View:updateBuffer(newbuffer)
  self.backbuffer = newbuffer
end

function View:popSelectedCard()
  return table.remove(self.backbuffer, self.selection)
end

function View:isBufferEmpty()
  return #self.backbuffer == 0
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
  g.setColor(0, 0, 0, enter*0x80)
  g.rectangle("fill", 0, 0, _width, _height)
end

function View:drawCards(g, enter)
  local _PD = 40
  local range = 3
  local selection = self.selection
  local buffer = self.backbuffer
  local buffer_size = #buffer

  g.push()

  -- smooth enter!
  g.translate(math.round((_width/2)*(1-enter)+_width/2-_cw/2),
              math.round(3*_height/7-_ch/2))

  -- smooth movement!
  self.move = self.move + (selection - self.move)*_MOVE_SMOOTH
  if (self.move-selection)^2 <= _EPSILON then self.move = selection end
  g.translate(math.round(-(_cw+_PD)*(self.move-1)), 0)

  -- draw each card
  for i = 1, buffer_size do
    g.push()
    local focus = selection == i
    local dist = (selection-i)^2
    local offset = self.offsets[i] or 0

    -- smooth offset when consuming cards
    offset = offset > _EPSILON and offset - offset * _MOVE_SMOOTH or 0
    self.offsets[i] = offset
    g.translate((_cw+_PD)*(i-1+offset), 0)

    CARD.draw(buffer[i].card, 0, 0, focus, dist>0 and enter/dist or enter)
    g.pop()
  end
  g.pop()

  -- draw selection
  g.push()
  g.translate(math.round(_width/2),
              math.round(3*_height/7-_ch/2))
  self:drawArrow(g, enter)
  if buffer[selection] then
    self:drawCardDesc(g, buffer[selection].card, enter)
  end
  g.pop()
end

function View:drawArrow(g, enter)
  local text_width = _font:getWidth(_CONSUME_TEXT)
  local lh = 1.25
  local text_height
  local senoid

  g.push()
  g.setColor(0xFF, 0xFF, 0xFF, enter*0xFF)

  -- move arrow in senoid
  self.cursor = self.cursor + _SIN_INTERVAL
  while self.cursor > 1 do self.cursor = self.cursor - 1 end
  senoid = (_ARRSIZE/2)*math.sin(self.cursor*_PI)

  _font:setLineHeight(lh)
  _font.set()
  text_height = _font:getHeight()*lh

  g.translate(0, -_PD - text_height)
  g.printf(_CONSUME_TEXT, -text_width/2, 0, text_width, "center")

  g.translate(-_ARRSIZE/2, _PD + text_height - _ARRSIZE - senoid)
  g.polygon("fill", 0, 0, _ARRSIZE/2, -_ARRSIZE, _ARRSIZE, 0)

  g.pop()
end

function View:drawCardDesc(g, card, enter)
  g.push()
  g.translate(-1.5*_cw, _ch+_PD)
  CARD.drawInfo(card, 0, 0, 4*_cw, enter)
  g.pop()
end

return View

