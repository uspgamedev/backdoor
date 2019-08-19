
-- luacheck: globals love

local FONT        = require 'view.helpers.font'
local COLORS      = require 'domain.definitions.colors'
local ACTIONDEFS  = require 'domain.definitions.action'

local math        = require 'common.math'
local Class       = require "steaming.extra_libs.hump.class"
local ELEMENT     = require "steaming.classes.primitives.element"
local RES         = require 'resources'

--CONSTS--
local _WIDTH, _HEIGHT
local _F_NAME = "Title" --Font name
local _F_SIZE = 24 --Font size
local _BG = COLORS.HUD_BG

local _font

--FocusBar Class--

local FocusBar = Class{
  __includes = { ELEMENT }
}

--CLASS FUNCTIONS--

function FocusBar:init(route, handview)

  ELEMENT.init(self)

  _WIDTH, _HEIGHT = love.graphics.getDimensions()

  self.x, self.y = (3*_WIDTH/4)/2, _HEIGHT - 50
  self.route = route
  self.actor = nil

  --Emergency effect
  self.emer_fx_alpha = 0
  self.emer_fx_max = math.pi
  self.emer_fx_speed = 3.5
  self.emer_fx_v = math.sin(self.emer_fx_alpha)

  -- Hide
  self.hidden = true
  self.v_offset = 1

  self.handview = handview

  _font = _font or FONT.get(_F_NAME, _F_SIZE)

end

function FocusBar:show()
  self.hidden = false
end

function FocusBar:hide()
  self.hidden = true
end

function FocusBar:update(dt)
  local _OFF_SPD = 2
  self.actor = self.route.getControlledActor()
  --update emergency effect
  self.emer_fx_alpha = self.emer_fx_alpha + self.emer_fx_speed*dt
  self.emer_fx_v = math.sin(self.emer_fx_alpha)
  while self.emer_fx_alpha >= self.emer_fx_max do
    self.emer_fx_alpha = self.emer_fx_alpha - self.emer_fx_max
  end

  if self.hidden then
    self.v_offset = self.v_offset + (1 - self.v_offset) * dt * _OFF_SPD
    if self.v_offset > 0.99 then self.v_offset = 1 end
  else
    self.v_offset = self.v_offset + (0 - self.v_offset) * dt * _OFF_SPD * 4
    if self.v_offset < 0.01 then self.v_offset = 0 end
  end
end

function FocusBar:draw()
  if not self.actor then return end
  local g = love.graphics

  -- draw hand countdown
  local maxfocus = ACTIONDEFS.MAX_FOCUS
  local focus = math.min(self.actor:getFocus(), maxfocus)
  local handbar_width = 492/4
  local handbar_height = 12
  local font = FONT.get("Text", 18)
  local mx, my = 60, 20
  local slope = handbar_height + 2*my
  font:set()
  g.push()
  g.origin()
  g.translate(0, self.v_offset * 60)
  g.translate(self.x - handbar_width/2, _HEIGHT - handbar_height - my)

  --Drawing background
  g.setColor(_BG)
  g.polygon('fill', -mx, handbar_height+my,
                    -mx + slope, -my,
                    handbar_width + mx - slope, -my,
                    handbar_width + mx, handbar_height + my)
  --Drawing focus bar
  g.setLineWidth(1)
  local red, gre, blu, a = unpack(COLORS.WARNING)
  red, gre, blu = red + (1-red)*self.emer_fx_v,
                  gre + (1-gre)*self.emer_fx_v,
                  blu + (1-blu)*self.emer_fx_v
  g.push()
  g.translate(0, 0.3*(handbar_height + 2*my))
  local handbar_gap = handbar_width / (maxfocus-1)
  local focus_icon = RES.loadTexture('focus-icon')
  local iw, ih = focus_icon:getDimensions()
  for i=0,maxfocus-1 do
    g.push()
    g.translate(i * handbar_gap, 0)
    g.setColor(COLORS.EMPTY)
    g.draw(focus_icon, 0, 0, 0, 1, 1, iw/2, ih/2)
    if i < focus then
      g.setColor(COLORS.FOCUS)
      g.draw(focus_icon, 0, 0, 0, 1, 1, iw/2, ih/2)
      local focused_card_view = self.handview:getFocusedCard()
      if focused_card_view then
        local cost = focused_card_view.card:getCost()
        local alpha = a * math.min(1, (focus-i))
        if cost <= focus and i >= focus - cost then
          g.setColor(red, gre, blu, alpha)
          g.draw(focus_icon, 0, 0, 0, 1, 1, iw/2, ih/2)
        end
      end
    end
    g.pop()
  end
  g.pop()

  --Drawing contour lines
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(2)
  g.line(-mx, handbar_height+my,
         -mx + slope, -my,
         handbar_width + mx - slope, -my,
         handbar_width + mx, handbar_height + my)


  --Draw text
  g.translate(0, -20)
  g.setColor(COLORS.BLACK)
  g.printf("Focus Duration", 0, 0, handbar_width, 'center')
  g.translate(-1, -1)
  g.setColor(COLORS.NEUTRAL)
  g.printf("Focus Duration", 0, 0, handbar_width, 'center')
  g.pop()
end

return FocusBar
