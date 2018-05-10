
local Color = require 'common.color'
local VIEWDEFS = require 'view.definitions'

local _SMOOTH_FACTOR = 0.2

local _lifestates = {}

local LIFEBAR = {}

function LIFEBAR.draw(body, x, y)
  local g = love.graphics
  local id = body:getId()
  local current = _lifestates[id] or 0
  local hp = body:getHP()
  local max_hp = body:getMaxHP()
  current = current + (hp - current) * _SMOOTH_FACTOR
  if math.abs(hp - current) < 1 then
    current = hp
  end
  _lifestates[id] = current
  local percent = current / max_hp
  local hsvcol = { 0 + 100*percent, 240, 255 - 50*percent }
  local cr, cg, cb = Color.fromHSV(unpack(hsvcol)):unpack()
  local pi = math.pi
  local start = pi/2 - 2*pi/36
  local length = -2*pi/3
  g.push()
  g.translate(x, y)
  g.scale(1, 1/2)
  g.setLineWidth(8)
  g.setColor(0, 0, 0, 0.2)
  g.arc('line', 'open', 0, 0, 36, start, start + length, 32)
  g.setColor(cr, cg, cb, 0.5)
  g.arc('line', 'open', 0, 0, 36, start, start + length * percent, 32)
  g.pop()
end

return LIFEBAR

