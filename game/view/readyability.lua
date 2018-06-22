
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
local _MOVE_SPEED = 0.25

local _FONT_NAME = "Text"
local _FONT_SIZE = 20
local _MARGIN = 8
local _PADDING = 8
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
  _font:setFilter('linear', 'linear', 1)
end

local function _next(i, len, n)
  if n == 0 then return i end
  return _next(i % len + 1, len, n - 1)
end

local function _prev(i, len, n)
  if n == 0 then return i end
  return _prev((i - 2) % len + 1, len, n - 1)
end

local function _dist(i, j, len)
  local d = i - j
  if d > len/2 then
    d = d - len
  elseif d < -len/2 then
    d = d + len
  end
  return d
end

local function _drawContainer(g, width)
  local h = _font:getHeight() + _PADDING*2 + 2*_MARGIN + 4
  g.rectangle("fill",
    -_MARGIN*4,
    -h - _MARGIN,
    width + 4*_PADDING + _MARGIN*8,
    h*3
  )
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
  self.offset = abs(_dist(self.selection, previous, self.widget_count))
  self:removeTimer(_OFFSET_TIMER, MAIN_TIMER)
  self:addTimer(_OFFSET_TIMER, MAIN_TIMER, "tween", _MOVE_SPEED,
                self, {offset = 0}, "in-out-back")
end

function ReadyAbilityView:selectPrev()
  local previous = self.selection
  self.selection = _prev(self.selection, self.widget_count, 1)
  self.offset = -abs(_dist(self.selection, previous, self.widget_count))
  self:removeTimer(_OFFSET_TIMER, MAIN_TIMER)
  self:addTimer(_OFFSET_TIMER, MAIN_TIMER, "tween", _MOVE_SPEED,
                self, {offset = 0}, "in-out-back")
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
  local block_height = fh + 2*_PADDING + 2*_MARGIN + 4

  for index, widget in ipairs(widgets) do
    local str = widget:getName()
    if not widget:isWidgetPermanent() then
      str = _FMT:format(str, widget:getWidgetCharges() - widget:getUsages())
    end
    names[index] = str
    width = math.max(width, _font:getWidth(names[index]))
  end

  g.push()
  g.translate(
    3/4*_WIDTH - width - 64,
    _HEIGHT - _MARGIN - block_height)
  g.stencil(function()
    _drawContainer(g, width)
  end, "replace", 1)

  g.setStencilTest("gequal", 1)

  local box = {
    _MARGIN, 0,
    width + 2*_PADDING, 0,
    width + 2*_PADDING, fh + 2*_PADDING - _MARGIN,
    width + 2*_PADDING - _MARGIN, fh + 2*_PADDING,
    0, fh + 2*_PADDING,
    0, _MARGIN
  }
  local idx = _prev(selection, widget_count, 2)
  local count = 0
  while widget_count > 0 and count < 5 do
    local name = names[floor(idx)]
    local dist = _dist(selection, idx, widget_count)
    local a
    if (widget_count > 1 and count == 2)
       or (dist == 0 and widget_count == 1) then a = alpha
    else
      a = alpha * list_alpha * min(1, (1-abs((count - 2)/7*2)))
    end
    local transp = Color:new {1, 1, 1, a}
    local bgcolor = COLORS.DARKER * transp
    local fgcolor
    if (widget_count > 1 and count == 2)
       or (dist == 0 and widget_count == 1) then
      fgcolor = COLORS.NEUTRAL * transp
    else
      fgcolor = COLORS.HALF_VISIBLE * transp
    end
    g.push()
    if widget_count > 1 then
      g.translate(0, - block_height * (count - 2 + offset))
    else
      g.translate(0, - block_height * (-dist + offset))
    end
    if (widget_count > 1 and dist == 0 and count == 2)
       or (dist == 0 and widget_count <= 1) then
      g.translate(
        -0.1*(width + 2*(_PADDING + 2)),
        -0.1*(block_height)
      )
      g.scale(1.1, 1.1)
    end
    g.setColor(bgcolor)
    g.polygon("fill", box)
    g.setLineWidth(2)
    g.setColor(COLORS.HALF_VISIBLE * transp)
    g.polygon("line", box)
    g.setColor(fgcolor)
    g.printf(name, _PADDING, _PADDING, width)
    g.pop()
    idx = _next(idx, widget_count, 1)
    count = count + 1
  end

  g.setStencilTest()

  g.pop()
end

function ReadyAbilityView:enter()
  self:removeTimer(_FADE_TIMER, MAIN_TIMER)
  self:addTimer(_FADE_TIMER, MAIN_TIMER, "tween",
                .1, self, { alpha = 1 }, "linear")
end

function ReadyAbilityView:exit()
  self:removeTimer(_FADE_TIMER, MAIN_TIMER)
  self:addTimer(_FADE_TIMER, MAIN_TIMER, "tween",
                .1, self, { alpha = 0 }, "linear",
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

