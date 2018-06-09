
local RES     = require 'resources'
local APT     = require 'domain.definitions.aptitude'
local COLORS  = require 'domain.definitions.colors'
local FONT    = require 'view.helpers.font'
local PLAYSFX = require 'helpers.playsfx'

local abs = math.abs
local min = math.min
local max = math.max
local coresume = coroutine.resume
local cocreate = coroutine.create
local coyield = coroutine.yield
local delta = love.timer.getDelta

local _dt
local _barwidth
local _font
local _particles = {}
local _states = {}

local function _newParticleSource()
  local pixel = RES.loadTexture('pixel')
  local particles = love.graphics.newParticleSystem(pixel, 64)
  particles:setParticleLifetime(2)
  particles:setSizeVariation(1)
  particles:setRadialAcceleration(-16)
  particles:setSpeed(128)
  particles:setColors(COLORS.NEUTRAL, COLORS.TRANSP)
  particles:setEmissionArea("ellipse", 16, 16, 0, false)
  particles:setSizes(2, 4)
  return particles
end

local function _renderAttribute(g, data)
  local actor, attrname, particles = unpack(data)
  local progress = 0
  local lvl = actor:getAttribute(attrname)
  local rawlvl = actor:getAttrLevel(attrname)
  while true do
    -- update bar progress
    local upgrade = actor:getAttrUpgrade(attrname)
    local aptitude = actor:getAptitude(attrname)
    local total_prev = APT.CUMULATIVE_REQUIRED_ATTR_UPGRADE(aptitude, rawlvl)
    local total_next = APT.CUMULATIVE_REQUIRED_ATTR_UPGRADE(aptitude, rawlvl+1)
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
    local newrawlvl = actor:getAttrLevel(attrname)
    local step = (newrawlvl - rawlvl) / abs(newrawlvl - rawlvl)
    if newrawlvl ~= rawlvl and progress == 1 then
      PLAYSFX('get-item')
      particles:emit(32)
      local start = 0
      while start <= 0.5 do
        particles:emit(4)
        start = start + _dt
        coyield(rawlvl, lvl, progress)
      end
      rawlvl = rawlvl + step
      lvl = lvl + step
      progress = 0
    end

    -- yield
    coyield(rawlvl, lvl, progress)
  end
end

local ATTR = {}

function ATTR.init(width)
  _barwidth = width/4
  _font = FONT.get("Text", 20)
end

function ATTR.draw(g, actor, attrname)
  _dt = delta()
  local actorstate = _states[actor] or {}
  local attrstate = actorstate[attrname] or {
    co = cocreate(_renderAttribute),
    particles = _newParticleSource()
  }
  local particles = attrstate.particles
  local data = {actor, attrname, particles}
  local _, rawlvl, lvl, percent = assert(coresume(attrstate.co, g, data))
  actorstate[attrname] = attrstate
  _states[actor] = actorstate


  -- check if attribute is modified
  local diff = lvl - rawlvl
  local color = (diff > 0 and COLORS.VALID) or (diff < 0 and COLORS.WARNING)
                 or COLORS.NEUTRAL

  -- render bar
  particles:update(_dt)
  _font:set()
  g.push()
  g.setColor(COLORS.NEUTRAL)
  g.printf(
    {
      COLORS.NEUTRAL, attrname .. ": ",
      color,          ("%02d"):format(lvl)
    },
    0, 0, _barwidth, "left"
  )
  g.translate(0, 32)
  g.push()
  g.setColor(COLORS.EMPTY)
  g.rectangle("fill", 0, 0, _barwidth, 16)
  g.setColor(COLORS[attrname])
  g.rectangle("fill", 0, 0, percent*_barwidth, 16)
  g.setColor(COLORS.NEUTRAL)
  g.draw(particles, 32, -_font:getHeight()/2)
  g.pop()
  g.pop()
end

return ATTR

