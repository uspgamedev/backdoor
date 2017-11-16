
local TRIGGERS = require 'domain.definitions.triggers'
local WIDGET = {}

local _WIDTH  = 160
local _HEIGHT = 80
local _PD = 8

local _font
local _fmt

local function _init()
  _font = FONT.get("Text", 20)
  _fmt = string.format
end

function WIDGET.draw(widget, x, y, alpha)
  if not _font then _init() end
  local g = love.graphics

  g.push()
  g.setColor(0x1f, 0x1f, 0x1f, alpha*0xff)
  g.rectangle("fill", x, y, _WIDTH, _HEIGHT)
  g.translate(_PD, _PD)
  _font.set()
  g.setColor(0xff, 0xff, 0xff, alpha*0xff)
  g.printf(_fmt("%s\n%02d/%02d\n%s", widget:getName(),
                widget:getUsages(), widget:getWidgetCharges(),
                TRIGGERS[widget:getWidgetTrigger()]:gsub("_", " ")
          ), x, y, _WIDTH - _PD*2
  )
  g.pop()

end

function WIDGET.getWidth()
  return _WIDTH
end

function WIDGET.getHeight()
  return _HEIGHT
end

function WIDGET.getDimensions()
  return _WIDTH, _HEIGHT
end

return WIDGET

