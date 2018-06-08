
local APT    = require 'domain.definitions.aptitude'
local COLORS = require 'domain.definitions.colors'
local FONT   = require 'view.helpers.font'

local abs = math.abs

local _barwidth
local _states = {}

local ATTR = {}

function ATTR.init(width)
  _barwidth = width/4
end

function ATTR.draw(g, actor, attrname)
  local attrlvl = actor:getAttrLevel(attrname)
  local attrval = actor:getAttribute(attrname)
  local attrupgrade = actor:getAttrUpgrade(attrname)
  local attraptitude = actor:getAptitude(attrname)
  local required_next = APT.REQUIRED_ATTR_UPGRADE(attraptitude, attrlvl)
  local required_prev = APT.REQUIRED_ATTR_UPGRADE(attraptitude, attrlvl-1)
  local current = _states[attrname] or required_prev
  current = current + (attrupgrade - current)/8
  if abs(current - attrupgrade) < 1 then current = attrupgrade end
  _states[attrname] = current
  local percent = (current - required_prev) / (required_next - required_prev)
  FONT.set("Text", 20)
  g.push()
  g.setColor(COLORS.NEUTRAL)
  g.printf(
    {
      COLORS.NEUTRAL, attrname .. ": ",
      (attrval < attrlvl and COLORS.WARNING) or
      (attrval > attrlvl and COLORS.VALID) or
      COLORS.NEUTRAL,  ("%02d"):format(attrval),
    }, 0, 0, _barwidth, "left")
  g.translate(0, 32)
  g.setColor(COLORS.DARK)
  g.rectangle("fill", 0, 0, _barwidth, 16)
  g.setColor(COLORS[attrname])
  g.rectangle("fill", 0, 0, 0.5*_barwidth, 16)
  g.pop()
end

return ATTR

