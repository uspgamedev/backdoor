
local APT = require 'domain.definitions.aptitude'

local _SIGNATURE = "%s: %0d"

local _barwidth

local ATTR = {}

function ATTR.init(width)
  _barwidth = width/4
end

function ATTR.draw(g, actor, attrname)
  local attrlvl = actor:getAttrLevel(attrname)
  local attrval = actor:getAttribute(attrname)
  local required_next = APT.REQUIRED_ATTR_UPGRADE(
    actor:getAptitude(attrname), attrlvl
  )
  local required_previously = APT.REQUIRED_ATTR_UPGRADE(
    actor:getAptitude(attrname), attrlvl-1
  )
  g.push()
  g.setColor(COLORS.NEUTRAL)
  g.printf(_SIGNATURE:format(attrname, attrval), 0, 0, _barwidth, "left")
  g.translate(0, 32)
  g.setColor(COLORS.DARK)
  g.rectangle("fill", 0, 0, _barwidth, 16)
  g.setColor(COLORS[attribute])
  g.rectangle("fill", 0, 0, 0.4*_barwidth, 16)
  g.pop()
end

return ATTR

