
local TRIGGERS = require 'domain.definitions.triggers'
local FONT = require 'view.helpers.font'

local WIDGET = {}

local _WIDTH  = 160
local _HEIGHT
local _PD = 12
local _LH = .8

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
  g.rectangle("fill", x, y, WIDGET.getWidth(), WIDGET.getHeight())
  g.translate(_PD, _PD)
  _font:setLineHeight(_LH)
  _font.set()
  g.setColor(0xff, 0xff, 0xff, alpha*0xff)
  g.printf(_fmt("%s\n%s\n%02d/%02d", widget:getName():sub(1,16),
                widget:getWidgetTrigger():gsub("_", " "),
                widget:getWidgetCharges() - widget:getUsages(),
                widget:getWidgetCharges()
          ), x, y, _WIDTH - _PD*2
  )
  g.pop()

end

function WIDGET.getWidth()
  return _WIDTH
end

function WIDGET.getHeight(widget)
  if not _HEIGHT then
    if not _font then _init() end
    _font:setLineHeight(_LH)
    _HEIGHT = _font:getHeight()*3 + 2*_PD
  end
  return _HEIGHT
end

return WIDGET

