
local RES = require 'resources'
local Color = require 'common.color'
local DEFS = require 'domain.definitions'
local COLORS = require 'domain.definitions.colors'
local FONT = require 'view.helpers.font'

local PickWidgetView = Class{
  __includes = { ELEMENT }
}

local _FONT_NAME = "Text"
local _FONT_SIZE = 20
local _MARGIN = 4
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

function PickWidgetView:init(widgets)
  ELEMENT.init(self)

  self.widgets = widgets
  self.selection = 1
  self.alpha = 0

  _initGraphicValues()
end

function PickWidgetView:setSelection(n)
  self.selection = n
end

function PickWidgetView:draw()
  local g = love.graphics
  local alpha = self.alpha
  local widgets = self.widgets
  local fh = _font:getHeight()
  _font:set()

  -- draw stuff
  local strs = {}
  local width = 0
  for index, widget in ipairs(widgets) do
    strs[index] = _FMT:format(widget:getName(),
                              widget:getWidgetCharges() - widget:getUsages())
    width = math.max(width, _font:getWidth(strs[index]))
  end

  g.push()
  g.translate(3/4*_WIDTH - width - 4*_MARGIN, _HEIGHT - _MARGIN - fh)

  for index, info_str in ipairs(strs) do
    local selected = self.selection == index
    local transp = Color:new {1, 1, 1, selected and 1 or alpha}
    local bgcolor = (selected and COLORS.NEUTRAL or COLORS.DARK) * transp
    local fgcolor = (selected and COLORS.DARK or COLORS.NEUTRAL) * transp
    g.setColor(bgcolor)
    g.rectangle("fill", 0, 0, width+4*_PADDING, _font:getHeight())
    g.setColor(fgcolor)
    g.printf(info_str, 2*_PADDING, 0, width)
    g.translate(0, - _font:getHeight() - _MARGIN)
  end

  g.pop()
end

function PickWidgetView:fadeOut()
  self:removeTimer("widget_picker_fade", MAIN_TIMER)
  self:addTimer("widget_picker_fade", MAIN_TIMER, "tween",
                 .2, self, { alpha = 0 }, "out-quad",
                 function() self:destroy() end)
end

function PickWidgetView:fadeIn()
  self:removeTimer("widget_picker_fade", MAIN_TIMER)
  self:addTimer("widget_picker_fade", MAIN_TIMER, "tween",
                .25, self, { alpha = 1 }, "out-quad")
end

return PickWidgetView

