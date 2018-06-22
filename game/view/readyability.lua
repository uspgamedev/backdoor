
local RES = require 'resources'
local Color = require 'common.color'
local DEFS = require 'domain.definitions'
local COLORS = require 'domain.definitions.colors'
local FONT = require 'view.helpers.font'

local min = math.min
local abs = math.abs
local floor = math.floor

local ReadyAbilityView = Class{
  __includes = { ELEMENT }
}

local _FADE_TIMER = "FADE_TIMER"
local _LIST_TIMER = "LIST_TIMER"
local _OFFSET_TIMER = "READY_ABILITY_OFFSET_TIMER"

local _FONT_NAME = "Text"
local _FONT_SIZE = 20
local _MARGIN = 8
local _PADDING = 4
local _FMT = "%s (%d)"
local _TRIGGERS = {
  [DEFS.TRIGGERS.ON_USE] = " uses",
  [DEFS.TRIGGERS.ON_TURN] = " turns",
  [DEFS.TRIGGERS.ON_TICK] = " ticks",
}

local _WIDTH, _HEIGHT
local _font
local _alpha

local function _initGraphicValues()
  local g = love.graphics
  _WIDTH, _HEIGHT = g.getDimensions()
  _font = _font or FONT.get(_FONT_NAME, _FONT_SIZE)
end

local function _next(i, len, n)
  if n == 0 then return i end
  return _next(i % len + 1, len, n - 1)
end

local function _prev(i, len, n)
  if n == 0 then return i end
  return _prev((i - 2) % len + 1, len, n - 1)
end

function ReadyAbilityView:init(widgets, selection)
  ELEMENT.init(self)

  self.widgets = widgets
  self.widget_count = #widgets
  self.selection = selection
  self.offset = 0
  self.alpha = 0
  self.list_alpha = 0

  _initGraphicValues()
end

function ReadyAbilityView:setSelection(n)
  self.selection = n
end

function ReadyAbilityView:getSelection()
  return self.selection
end

function ReadyAbilityView:selectNext()
  local previous = self.selection
  self.selection = _next(self.selection, self.widget_count, 1)
  self.offset = self.selection - previous
  self:removeTimer(_OFFSET_TIMER, MAIN_TIMER)
  self:addTimer(_OFFSET_TIMER, MAIN_TIMER, "tween", 0.2,
                self, {offset = 0}, "out-quad")
end

function ReadyAbilityView:selectPrev()
  local previous = self.selection
  self.selection = _prev(self.selection, self.widget_count, 1)
  self.offset = self.selection - previous
  self:removeTimer(_OFFSET_TIMER, MAIN_TIMER)
  self:addTimer(_OFFSET_TIMER, MAIN_TIMER, "tween", 0.2,
                self, {offset = 0}, "out-quad")
end

function ReadyAbilityView:draw()
  local g = love.graphics
  local alpha = self.alpha
  local list_alpha = self.list_alpha
  local widgets = self.widgets
  local widget_count = #widgets
  local selection = self.selection
  local offset = self.offset
  local fh = _font:getHeight()
  _font:set()

  -- draw stuff
  local names = {}
  local width = 0
  local block_height = fh + _MARGIN

  for index, widget in ipairs(widgets) do
    local str = widget:getName()
    if not widget:isWidgetPermanent() then
      str = _FMT:format(str, widget:getWidgetCharges() - widget:getUsages())
    end
    names[index] = str
    width = math.max(width, _font:getWidth(names[index]))
  end

  g.push()
  g.translate(3/4*_WIDTH - width - 4*_MARGIN, _HEIGHT - _MARGIN*4 - fh)

  local range = min(4, widget_count)
  local idx = _prev(selection, widget_count, floor(range/2))
  local count = 0
  while range > 0 and count < range do
    local name = names[floor(idx)]
    local dist = selection - idx
    local a = (dist == 0) and alpha or alpha * list_alpha
    local transp = Color:new {1, 1, 1, a}
    local bgcolor = COLORS.DARK * transp
    local fgcolor
    if dist == 0 then
      fgcolor = COLORS.NEUTRAL * transp
    else
      fgcolor = COLORS.HALF_VISIBLE * transp
    end
    g.push()
    g.translate(0, - block_height * (idx - selection + offset))
    g.setColor(bgcolor)
    g.rectangle("fill", 0, 0, width+4*_PADDING, _font:getHeight())
    g.setColor(fgcolor)
    g.printf(name, 2*_PADDING, 0, width)
    g.pop()
    idx = _next(idx, widget_count, 1)
    count = count + 1
  end

  g.pop()
end

function ReadyAbilityView:enter()
  self:removeTimer(_FADE_TIMER, MAIN_TIMER)
  self:addTimer(_FADE_TIMER, MAIN_TIMER, "tween",
                .25, self, { alpha = 1 }, "linear")
end

function ReadyAbilityView:exit()
  self:removeTimer(_FADE_TIMER, MAIN_TIMER)
  self:addTimer(_FADE_TIMER, MAIN_TIMER, "tween",
                 .2, self, { alpha = 0 }, "linear",
                 function() self:destroy() end)
end

function ReadyAbilityView:enterList()
  self:removeTimer(_LIST_TIMER, MAIN_TIMER)
  self:addTimer(_LIST_TIMER, MAIN_TIMER, "tween",
                .25, self, { list_alpha = 1 }, "linear")
end

function ReadyAbilityView:exitList()
  self:removeTimer(_LIST_TIMER, MAIN_TIMER)
  self:addTimer(_LIST_TIMER, MAIN_TIMER, "tween",
                 .2, self, { list_alpha = 0 }, "linear")
end

return ReadyAbilityView

