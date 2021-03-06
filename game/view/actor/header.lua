
local COLORS = require 'domain.definitions.colors'
local FONT = require 'view.helpers.font'

local math = require 'common.math'
local abs = math.abs

local HEADER = {}

local _SIGNATURE = "%s %d/%d"
local _LENGTH

local _states = {}

function HEADER.init(width, mg, pd)
  _LENGTH = width - 2*mg - 2*pd
end

function HEADER.drawBar(g, attrname, current, max, color_full, color_empty,
                        extra)
  max = max + (extra or 0)
  local state = _states[attrname] or 0
  local percent = current/max
  state = state + (percent - state) * 1/8
  if abs(percent - state) <= 0.001 then state = percent end
  _states[attrname] = state

  FONT.set("Text", 20)
  g.push()
  g.setColor(COLORS.EMPTY)
  g.rectangle("fill", 0, 0, _LENGTH, 12)
  g.translate(-1, -1)
  g.setColor(state*color_full + (1-state)*color_empty)
  g.rectangle("fill", 0, 0, state*_LENGTH, 12)
  if extra then
    g.setColor(COLORS.NEUTRAL)
    g.rectangle("fill", state*_LENGTH, 0, extra/max*_LENGTH, 12)
  end
  g.translate(8, -16)
  g.setColor(COLORS.BLACK)
  local text = _SIGNATURE:format(attrname, current, max - (extra or 0))
  if extra and extra > 0 then text = text .. " +" .. extra end
  g.printf(text, 0, 0, _LENGTH-8, "left")
  g.translate(-2, -2)
  g.setColor(COLORS.NEUTRAL)
  g.printf(text, 0, 0, _LENGTH-8, "left")
  g.pop()
end

return HEADER

