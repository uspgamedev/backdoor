
-- luacheck: globals love

local Color  = require 'common.color'
local COLORS = require 'domain.definitions.colors'
local RES    = require 'resources'
local Text   = require 'view.helpers.text'

local _SMOOTH_FACTOR = 0.2

local _lifestates = {}

local LIFEBAR = {}

function LIFEBAR.draw(body, x, y)
  local g = love.graphics
  local id = body:getId()
  local current = _lifestates[id] or 0
  local hp = body:getHP()
  local max_hp = body:getMaxHP()
  local armor = body:getArmor()
  current = current + (hp - current) * _SMOOTH_FACTOR
  if math.abs(hp - current) < 1 then
    current = hp
  end
  _lifestates[id] = current
  local hppercent = current / (max_hp + armor)
  local hsvcol = { 0 + 100*hppercent, 240, 255 - 50*hppercent, 1 }
  local color = Color.fromHSV(unpack(hsvcol))
  local icon = RES.loadTexture("hp-icon")
  local iw, ih = icon:getDimensions()
  g.push()
  g.translate(x, y)

  g.translate(32, 12)
  g.setColor(COLORS.NEUTRAL)
  g.draw(icon, 0, 0, 0, 1, 1, iw/2, ih/2)
  local text = Text(hp, 'Text', 18, { dropshadow = true, align = 'center',
                                      width = 36, color = color })
  text:draw(-18, -text.font:getHeight()/2)
  g.pop()
end

return LIFEBAR

