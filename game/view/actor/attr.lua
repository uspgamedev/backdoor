
local APT    = require 'domain.definitions.aptitude'
local COLORS = require 'domain.definitions.colors'
local FONT   = require 'view.helpers.font'

local abs = math.abs
local min = math.min
local max = math.max

local _barwidth
local _states = {}

local ATTR = {}

function ATTR.init(width)
  _barwidth = width/4
end

function ATTR.draw(g, actor, attrname)
  local lvl = actor:getAttrLevel(attrname)
  local val = actor:getAttribute(attrname)
  local diff = val - lvl
  local upgrade = actor:getAttrUpgrade(attrname)
  local aptitude = actor:getAptitude(attrname)
  local total_prev = APT.CUMULATIVE_REQUIRED_ATTR_UPGRADE(aptitude, lvl)
  local total_next = APT.CUMULATIVE_REQUIRED_ATTR_UPGRADE(aptitude, lvl+1)
  local current = _states[attrname] or total_prev
  current = min(total_next, max(total_prev, current + (upgrade - current)/8))
  if abs(current - upgrade) < 1 then current = upgrade end
  _states[attrname] = current
  local percent = (current - total_prev) / (total_next - total_prev)
  local color = (diff > 0 and COLORS.VALID) or (diff < 0 and COLORS.WARNING)
                or COLORS.NEUTRAL
  FONT.set("Text", 20)
  g.push()
  printf([=[%s:
  current: %d (%03.02f%%)
  previous: %d
  next: %d
  level %d
  apt: %d
  ]=], attrname, upgrade, 100*percent, total_prev, total_next, lvl, aptitude)
  g.setColor(COLORS.NEUTRAL)
  g.printf({ COLORS.NEUTRAL, attrname .. ": ",
             color,  ("%02d"):format(val) }, 0, 0, _barwidth, "left")
  g.translate(0, 32)
  g.setColor(COLORS.DARK)
  g.rectangle("fill", 0, 0, _barwidth, 16)
  g.setColor(COLORS[attrname])
  g.rectangle("fill", 0, 0, percent*_barwidth, 16)
  g.pop()
end

return ATTR

