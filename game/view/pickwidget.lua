
local RES = require 'resources'
local DEFS = require 'domain.definitions'
local Color = require 'common.color'
local COLOR = require 'common.color'
local FONT = require 'view.helpers.font'

local PickWidgetView = Class{
  __includes = { ELEMENT }
}

local _FONT_NAME = "Text"
local _FONT_SIZE = 24
local _BLOCK_HEIGHT = 48
local _MARGIN = 16
local _PADDING = 4
local _FMT = "%s [%d/%d%s]"
local _TRIGGERS = {
  [DEFS.TRIGGERS.ON_USE] = " uses",
  [DEFS.TRIGGERS.ON_TURN] = " turns",
  [DEFS.TRIGGERS.ON_TICK] = " ticks",
}

local _width, _height
local _font
local _alpha

local function _initGraphicValues()
  local g = love.graphics
  _width, _height = g.getDimensions()
  _font = _font or FONT.get(_FONT_NAME, _FONT_SIZE)
end

function PickWidgetView:init(target_actor)
  ELEMENT.init(self)

  self.target = target_actor
  self.selection = 1
  self.alpha = 0

  _initGraphicValues()
end

function PickWidgetView:setSelection(n)
  self.selection = n
end

function PickWidgetView:draw()
  local g = love.graphics
  g.setColor(0, 0, 0, self.alpha*0.5)
  g.rectangle("fill", 0, 0, _width, _height)
  g.push()

  g.translate(_width/8, _height/2-2*(_BLOCK_HEIGHT+_MARGIN))
  -- draw stuff
  local strs = {}
  local width = 0
  for index, widget in self.target:getBody():eachWidget() do
    strs[index] = _FMT:format(widget:getName(),
                              widget:getWidgetCharges() - widget:getUsages(),
                              widget:getWidgetCharges(),
                              _TRIGGERS[widget:getWidgetTrigger()] or ""
    )
    width = math.max(width, _font:getWidth(strs[index]))
  end
  for index, info_str in ipairs(strs) do
    local selected = self.selection == index
    if selected then
      g.setColor(Color.fromInt(0xff, 0xff, 0xff, self.alpha*0xff))
    else
      g.setColor(Color.fromInt(0x16, 0x16, 0x16, self.alpha*0xff))
    end
    g.rectangle("fill", 0, 0, width+8*_PADDING, _BLOCK_HEIGHT)
    _font:set()
    if selected then
      g.setColor(Color.fromInt(0x00, 0x00, 0x00, self.alpha*0xff))
    else
      g.setColor(Color.fromInt(0xff, 0xff, 0xff, self.alpha*0xff))
    end
    g.printf(info_str, 4*_PADDING, _PADDING, width)
    g.translate(0, _BLOCK_HEIGHT + _MARGIN)
  end

  g.pop()
end

function PickWidgetView:fadeOut()
  self:removeTimer("widget_picker_fade", MAIN_TIMER)
  self:addTimer("widget_picker_fade", MAIN_TIMER, "tween",
                 .2, self, { alpha = 0 }, "out-quad",
                 function () self:destroy() end)
end

function PickWidgetView:fadeIn()
  self:removeTimer("widget_picker_fade", MAIN_TIMER)
  self:addTimer("widget_picker_fade", MAIN_TIMER, "tween",
                .25, self, { alpha = 1 }, "out-quad")
end

return PickWidgetView

