
local RES     = require 'resources'
local RANDOM  = require 'common.random'
local APT     = require 'domain.definitions.aptitude'
local COLORS  = require 'domain.definitions.colors'
local FONT    = require 'view.helpers.font'
local PLAYSFX = require 'helpers.playsfx'

local abs  = math.abs
local min  = math.min
local max  = math.max
local pi   = math.pi
local fmod = math.fmod

local coresume = coroutine.resume
local cocreate = coroutine.create
local coyield  = coroutine.yield

local delta = love.timer.getDelta

local _dt
local _barwidth
local _font
local _rot = 0
local _particles = {}
local _states = {}

local function _newParticleSource()
  local pixel = RES.loadTexture('pixel')
  local particles = love.graphics.newParticleSystem(pixel, 128)
  particles:setParticleLifetime(.75)
  particles:setSizeVariation(0)
  particles:setLinearDamping(6)
  particles:setSpeed(256)
  particles:setSpread(2*pi)
  particles:setColors(COLORS.NEUTRAL, COLORS.TRANSP)
  particles:setSizes(4)
  particles:setEmissionArea('ellipse', 0, 0, 0, false)
  particles:setTangentialAcceleration(-512)
  return particles
end

local function _renderAttribute(data)
  local g = love.graphics
  local actor, attrname, particles = unpack(data)
  local progress = 0
  local lvl = actor:getAttrLevel(attrname)
  while true do
    -- update bar progress
    local upgrade = actor:getAttrUpgrade(attrname)
    local aptitude = actor:getAptitude(attrname)
    local total_prev = APT.CUMULATIVE_REQUIRED_ATTR_UPGRADE(aptitude, lvl)
    local total_next = APT.CUMULATIVE_REQUIRED_ATTR_UPGRADE(aptitude, lvl+1)
    local target = min(1 ,
      max(0, (upgrade - total_prev) / (total_next - total_prev))
    )
    progress = min(
      1, max(0, progress + 8*(target-progress)*_dt)
    )
    if abs(target - progress) < 0.01 then
      progress = target
    end

    -- check if level up
    local newlvl = actor:getAttrLevel(attrname)
    local offset = newlvl - lvl
    local step = offset / abs(offset)
    if newlvl ~= lvl and progress == 1 then
      lvl = lvl + step
      offset = offset - step
      progress = 0
      particles:emit(48)
      PLAYSFX('get-item')
      local start = 0
      local rand = RANDOM.safeGenerate
      while start <= 0.5 do
        g.translate(2*(rand()*2-1), 2*(rand()*2-1))
        start = start + _dt
        coyield(lvl, offset, progress, true)
      end
    end

    -- yield
    coyield(lvl, offset, progress)
  end
end

local ATTR = {}

function ATTR.init(width)
  _barwidth = width/4
  _font = FONT.get("Text", 20)
end

function ATTR.draw(g, actor, attrname)
  g.push()
  _dt = delta()
  local actorstate = _states[actor] or {}
  local attrstate = actorstate[attrname] or {
    co = cocreate(_renderAttribute),
    particles = _newParticleSource()
  }
  local particles = attrstate.particles
  local data = {actor, attrname, particles}
  local _, rawlvl, offset, percent, rise = assert(coresume(attrstate.co, data))
  actorstate[attrname] = attrstate
  _states[actor] = actorstate


  -- check if attribute is modified
  local lvl = actor:getAttribute(attrname) - offset
  local diff = lvl - rawlvl
  local color = (diff > 0 and COLORS.VALID) or
                (diff < 0 and COLORS.WARNING) or
                COLORS.NEUTRAL

  -- render bar
  particles:update(_dt)
  _font:set()
  g.setColor(COLORS.NEUTRAL)
  g.printf(
    {
      COLORS.NEUTRAL,
      ("%s: "):format(attrname),
      rise and COLORS.NEUTRAL or color,
      ("%02d"):format(lvl)
    },
    0, 0, _barwidth, "left"
  )
  g.translate(0, 32)
  g.push()
  if not rise then
    g.setColor(COLORS.EMPTY)
  end
  g.rectangle("fill", 0, 0, _barwidth, 16)
  if not rise then 
    g.setColor(COLORS[attrname])
  end
  g.rectangle("fill", 0, 0, percent*_barwidth, 16)
  g.setColor(COLORS.NEUTRAL)
  g.pop()
  --_rot = fmod(_rot - 0.5*pi*_dt, 2*pi)
  g.draw(particles, 48, -_font:getHeight()/2, _rot)
  g.pop()
end

return ATTR

