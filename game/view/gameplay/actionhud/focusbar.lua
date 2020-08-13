
-- luacheck: globals love SWITCHER GS MAIN_TIMER

local FONT        = require 'view.helpers.font'
local COLORS      = require 'domain.definitions.colors'
local VIEWDEFS    = require 'view.definitions'
local SWITCHER    = require 'infra.switcher'
local ACTIONDEFS  = require 'domain.definitions.action'
local PLAYSFX     = require 'helpers.playsfx'

local math        = require 'common.math'
local Class       = require "steaming.extra_libs.hump.class"
local ELEMENT     = require "steaming.classes.primitives.element"
local RES         = require 'resources'

--CONSTS--
local _WIDTH, _HEIGHT
local _F_NAME = "Title" --Font name
local _F_SIZE = 24 --Font size
local _PI = math.pi
local _BG = COLORS.HUD_BG
local _HANDBAR_WIDTH = 492/8
local _HANDBAR_HEIGHT = 12
local _MARGIN_WIDTH = 60
local _MARGIN_HEIGHT = 16
local _PAD_HEIGHT = 32
local _SLOPE = _HANDBAR_HEIGHT + _MARGIN_HEIGHT
local FADE_IN_SPEED = 5
local FADE_OUT_SPEED = 6
local _PANEL_VTX = {
  -_MARGIN_WIDTH, _HANDBAR_HEIGHT / 2,
  -_MARGIN_WIDTH + _SLOPE, -_MARGIN_HEIGHT / 2,
  _HANDBAR_WIDTH + _MARGIN_WIDTH - _SLOPE, -_MARGIN_HEIGHT / 2,
  _HANDBAR_WIDTH + _MARGIN_WIDTH, _HANDBAR_HEIGHT / 2,
  _HANDBAR_WIDTH + _MARGIN_WIDTH - _SLOPE, _HANDBAR_HEIGHT + _MARGIN_HEIGHT / 2,
  -_MARGIN_WIDTH + _SLOPE, _HANDBAR_HEIGHT + _MARGIN_HEIGHT / 2,
}

local _font

--Local functions

local _newExplosionSource
local _renderExplosion

--FocusBar Class--

local FocusBar = Class{
  __includes = { ELEMENT }
}

--CLASS FUNCTIONS--

function FocusBar:init(route, handview)

  ELEMENT.init(self)

  _WIDTH, _HEIGHT = VIEWDEFS.VIEWPORT_DIMENSIONS()

  self.x, self.y = _WIDTH/2, _HEIGHT - _HANDBAR_HEIGHT - _MARGIN_HEIGHT - _PAD_HEIGHT
  self.route = route
  self.actor = nil


  --Var for creating/destroying focus
  self.previous_focus = 0
  self.fade_in = {}
  for i = 1, ACTIONDEFS.MAX_FOCUS do
    self.fade_in[i] = 0
  end
  self.explosions = {}
  for i = 1, ACTIONDEFS.MAX_FOCUS do
    self.explosions[i] = _newExplosionSource()
  end



  --Emergency effect
  self.emer_fx_alpha = 0
  self.emer_fx_max = math.pi
  self.emer_fx_speed = 3.5
  self.emer_fx_v = math.sin(self.emer_fx_alpha)

  self.handview = handview

  _font = _font or FONT.get(_F_NAME, _F_SIZE)

end

function FocusBar:update(dt)

  for i = 1, ACTIONDEFS.MAX_FOCUS do
    self.explosions[i]:update(dt)
  end

  self.actor = self.route.getPlayerActor()

  --update fade-in
  local maxfocus = ACTIONDEFS.MAX_FOCUS
  local focus = math.floor(math.min(self.actor:getFocus(), maxfocus))
  if focus < self.previous_focus then
    for i = focus + 1, self.previous_focus do
      self:addTimer(nil, MAIN_TIMER, "after", (i-1)*.05,
          function()
            PLAYSFX('focus-used')
            self.explosions[i]:emit(40)
          end)
    end
  elseif focus > self.previous_focus then
    for i = focus, self.previous_focus + 1, -1  do
      self:addTimer(nil, MAIN_TIMER, "after", (i-1)*.05,
          function()
            PLAYSFX('focus-gain')
            self.explosions[i]:emit(20)
          end)
    end
  end
  self.previous_focus = focus
  for i = 1, maxfocus do
    if i <= focus then
      self.fade_in[i] = math.min(self.fade_in[i] + FADE_IN_SPEED*dt, 1)
    else
      self.fade_in[i] = math.max(self.fade_in[i] - FADE_OUT_SPEED*dt, 0)
    end
  end

  --update emergency effect
  self.emer_fx_alpha = self.emer_fx_alpha + self.emer_fx_speed*dt
  self.emer_fx_v = math.sin(self.emer_fx_alpha)
  while self.emer_fx_alpha >= self.emer_fx_max do
    self.emer_fx_alpha = self.emer_fx_alpha - self.emer_fx_max
  end
end

function FocusBar:draw()
  if not self.actor then return end
  local g = love.graphics

  -- draw hand countdown
  local maxfocus = ACTIONDEFS.MAX_FOCUS
  local focus = math.floor(math.min(self.actor:getFocus(), maxfocus))
  local font = FONT.get("Text", 18)
  font:set()
  g.push()
  g.origin()
  g.translate(self.x - _HANDBAR_WIDTH/2, self.y)

  --Drawing background
  g.setColor(_BG)
  g.polygon('fill', _PANEL_VTX)
  --Drawing focus bar
  g.setLineWidth(1)
  local red, gre, blu, a = unpack(COLORS.WARNING)
  red, gre, blu = red + (1-red)*self.emer_fx_v,
                  gre + (1-gre)*self.emer_fx_v,
                  blu + (1-blu)*self.emer_fx_v
  g.push()
  g.translate(-_MARGIN_WIDTH / 4, _HANDBAR_HEIGHT / 2)
  local handbar_gap = (_HANDBAR_WIDTH + _MARGIN_WIDTH/2) / (maxfocus-1)
  local focus_icon = RES.loadTexture('focus-icon')
  local iw, ih = focus_icon:getDimensions()
  for i=0,maxfocus-1 do
    g.push()
    --Draw focus blank
    g.translate(i * handbar_gap, 0)
    g.setColor(COLORS.EMPTY)
    g.draw(focus_icon, 0, 0, 0, 1, 1, iw/2, ih/2)

    --Draw the focus gem
    g.setColor(COLORS.FOCUS[1], COLORS.FOCUS[2], COLORS.FOCUS[3], self.fade_in[i+1])
    g.draw(focus_icon, 0, 0, 0, 1, 1, iw/2, ih/2)
    local focused_card_view = self.handview:getFocusedCard()
    if focused_card_view and
      (self.handview:isActive() or
       SWITCHER.current() == GS.PICK_DIR or
       SWITCHER.current() == GS.PICK_TARGET) then
      local cost = focused_card_view.card:getCost()
      local alpha = a * math.min(1, (focus-i))
      if cost <= focus and i >= focus - cost then
        g.setColor(red, gre, blu, alpha*self.fade_in[i+1])
        g.draw(focus_icon, 0, 0, 0, 1, 1, iw/2, ih/2)
      end
    end

    --Draw explosions
    _renderExplosion(self.explosions[i+1], 0, 0)

    g.pop()
  end
  g.pop()

  --Drawing contour lines
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(2)
  g.polygon('line', _PANEL_VTX)

  g.pop()
end

function _newExplosionSource()
  local pixel = RES.loadTexture('pixel')
  local particles = love.graphics.newParticleSystem(pixel, 128)
  particles:setParticleLifetime(.5)
  particles:setSizeVariation(0)
  particles:setLinearDamping(5)
  particles:setSpeed(256)
  particles:setSpread(2*_PI)
  particles:setColors(COLORS.NEUTRAL, COLORS.TRANSP)
  particles:setSizes(3)
  particles:setEmissionArea('ellipse', 0, 0, 0, false)
  return particles
end

function _renderExplosion(explosion, x, y)
  local g = love.graphics
  g.push()
  g.translate(x , y)
  g.setColor(COLORS.NEUTRAL)
  g.draw(explosion, 0, 0)
  g.pop()
end

return FocusBar
