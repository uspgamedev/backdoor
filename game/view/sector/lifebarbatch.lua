
-- luacheck: globals love

local Color  = require 'common.color'
local COLORS = require 'domain.definitions.colors'
local Text   = require 'view.helpers.text'
local Class  = require "steaming.extra_libs.hump.class"

local _SMOOTH_FACTOR = 0.05

local LifebarBatch = Class()

function LifebarBatch:init()
  self.lifestates = {}
end

function LifebarBatch:reset(body)
  self.lifestates[body:getId()] = 0
end

function LifebarBatch:drawFor(body, x, y)
  local g = love.graphics
  local id = body:getId()
  local current = self.lifestates[id] or 0
  local hp = body:getHP()
  local max_hp = body:getMaxHP()
  current = current + (hp - current) * _SMOOTH_FACTOR
  current = math.min(current, max_hp)
  if math.abs(hp - current) < 1 then
    current = hp
  end
  self.lifestates[id] = current
  local pi = math.pi
  local start = pi/2 - 3*pi/36
  local length = -2*pi/3
  local hppercent = current / max_hp
  local real_hppercent = hp / max_hp
  local hsvcol = { 0 + 100*real_hppercent, 240, 200 - 50*real_hppercent, 1 }
  local color = Color.fromHSV(unpack(hsvcol))
  local cr, cg, cb = color:unpack()
  g.push()
  g.translate(x, y)

  g.push()
  g.scale(1, 1/2)
  g.setLineWidth(8)
  g.setColor(0, 0, 0, 0.2)
  g.arc('line', 'open', 0, 0, 42, start, start + length, 32)
  g.setColor(cr, cg, cb, 1)
  g.arc('line', 'open', 0, 0, 42, start, start + length * hppercent, 32)
  g.pop()

  g.translate(0, 20)
  g.scale(1, 1)
  g.setColor(cr, cg, cb, 1)
  g.circle('fill', 0, 0, 14, 16)
  local text = Text(hp, 'Text', 18, { dropshadow = true, align = 'center',
                                      width = 36, color = COLORS.NEUTRAL })
  text:draw(-18, -text.font:getHeight()/2)
  g.pop()
end

return LifebarBatch

