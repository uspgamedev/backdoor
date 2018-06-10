
local RES        = require 'resources'
local FONT       = require 'view.helpers.font'
local ACTIONDEFS = require 'domain.definitions.action'
local COLORS     = require 'domain.definitions.colors'
local DEFS       = require 'domain.definitions'

local ACTOR_PANEL   = require 'view.actor.panel'
local ACTOR_HEADER  = require 'view.actor.header'
local ACTOR_MINIMAP = require 'view.actor.minimap'
local ACTOR_ATTR    = require 'view.actor.attr'
local ACTOR_WIDGETS = require 'view.actor.widgets'

local math = require 'common.math'

local ActorView = Class{
  __includes = { ELEMENT }
}

local _PANEL_MG = 24
local _PANEL_PD = 8
local _PANEL_WIDTH
local _PANEL_HEIGHT
local _PANEL_INNERWIDTH

local _WIDTH, _HEIGHT


local function _initGraphicValues()
  local g = love.graphics
  _WIDTH, _HEIGHT = g.getDimensions()
  -- panel
  _PANEL_WIDTH = g.getWidth()/4
  _PANEL_HEIGHT = g.getHeight()
  _PANEL_INNERWIDTH = _PANEL_WIDTH - 2*_PANEL_PD - 2*_PANEL_MG
  ACTOR_PANEL.init(_PANEL_WIDTH, _PANEL_HEIGHT, _PANEL_MG)
  -- header
  ACTOR_HEADER.init(_PANEL_WIDTH, _PANEL_MG, _PANEL_PD)
  -- minimap
  ACTOR_MINIMAP.init(_PANEL_INNERWIDTH, 192)
  -- attributes
  ACTOR_ATTR.init(_PANEL_INNERWIDTH)
  -- widgets
  ACTOR_WIDGETS.init()
end

function ActorView:init(route)

  ELEMENT.init(self)

  self.route = route
  self.actor = false

  _initGraphicValues()

end

function ActorView:loadActor()
  local newactor = self.route.getControlledActor()
  if self.actor ~= newactor and newactor then
    self.actor = newactor
  end
  return self.actor
end

function ActorView:draw()
  local g = love.graphics
  local actor = self:loadActor()
  if not actor then return end
  local cr,cg,cb = unpack(COLORS.NEUTRAL)

  -- always visible
  g.push()
  self:drawPanel(g)
  self:drawHP(g, actor)
  self:drawMiniMap(g, actor)
  self:drawAttributes(g, actor)
  self:drawWidgets(g, actor)
  g.pop()

  -- only visible when holding button
  if DEV then
    local font = FONT.get("Text", 20)
    local fps_str = ("fps: %d"):format(love.timer.getFPS())
    font:set()
    g.setColor(1, 1, 1, 1)
    g.print(fps_str, g.getWidth()- 40 - font:getWidth(fps_str),
            g.getHeight() - 24)
  end
end

function ActorView:drawPanel(g)
  g.setColor(COLORS.NEUTRAL)
  g.translate(3/4*g.getWidth(), 0)
  ACTOR_PANEL.draw(g, -_PANEL_MG*2, -_PANEL_MG)
end

function ActorView:drawHP(g, actor)
  local body = actor:getBody()
  local hp, pp = body:getHP(), actor:getPP()
  local max_hp, max_pp = body:getMaxHP(), DEFS.MAX_PP
  -- character name
  FONT.set("TextBold", 24)
  g.translate(_PANEL_MG, _PANEL_MG)
  g.setColor(COLORS.NEUTRAL)
  g.printf(actor:getTitle(), 0, -8, _PANEL_INNERWIDTH, "left")
  -- character hp & pp
  g.translate(0, 48)
  ACTOR_HEADER.drawBar(g, "HP", hp, max_hp, COLORS.SUCCESS, COLORS.NOTIFICATION)
  g.translate(0, 32)
  ACTOR_HEADER.drawBar(g, "PP", pp, max_pp, COLORS.PP, COLORS.PP)
end

function ActorView:drawMiniMap(g, actor)
  local sector = self.route.getCurrentSector()
  ACTOR_MINIMAP.draw(g, actor, sector)
end

function ActorView:drawAttributes(g, actor)
  FONT.set("Text", 20)
  g.translate(_PANEL_MG*4/3, 2*_PANEL_MG + 192)

  -- exp
  g.push()
  g.translate(0, -32)
  g.setColor(COLORS.NEUTRAL)
  g.print(("EXP: %02d"):format(actor:getExp()), 0, 0)

  -- packs
  local packcount = actor:getPrizePackCount()
  local packcolor = packcount > 0 and COLORS.VALID or COLORS.NEUTRAL
  local packstr = {
    COLORS.NEUTRAL, "PACKS: ",
    packcolor, ("%02d"):format(packcount)
  }
  g.translate(_PANEL_INNERWIDTH/2 - 24, 0)
  g.setColor(COLORS.NEUTRAL)
  g.print(packstr, 0, 0)
  g.pop()

  -- attributes
  g.push()
  ACTOR_ATTR.draw(g, actor, 'COR')
  g.translate(_PANEL_INNERWIDTH/4 + _PANEL_MG/2, 0)
  ACTOR_ATTR.draw(g, actor, 'ARC')
  g.translate(_PANEL_INNERWIDTH/4 + _PANEL_MG/2, 0)
  ACTOR_ATTR.draw(g, actor, 'ANI')
  g.pop()
end

function ActorView:drawWidgets(g, actor)
  g.push()
  g.translate(0, 16)
  for wtype = 1, 3 do
    ACTOR_WIDGETS.draw(g, actor, wtype)
  end
  g.pop()
end

return ActorView

