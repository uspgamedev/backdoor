
local COLORS = require 'domain.definitions.colors'

local Node      = require 'view.node'
local Text      = require 'view.helpers.text'
local VIEWDEFS  = require 'view.definitions'
local Class     = require "steaming.extra_libs.hump.class"

local LifeBar = require 'view.actorpanel.lifebar'
local Stats   = require 'view.actorpanel.stats'
local Widgets = require 'view.actorpanel.widgets'

local ActorHudTree = Class({ __includes = { Node } })

local _WIDTH, _HEIGHT = 320, 720
local _MG = VIEWDEFS.PANEL_MG
local _PD = 8
local _INNERWIDTH = _WIDTH - 2*_PD - 2*_MG

function ActorHudTree:init(actor)
  Node.init(self)
  self.actor = actor
  -- subtrees for each section
  local route = actor:getBody():getSector():getRoute()
  local name = ("%s the %s"):format(route.getPlayerName(), actor:getTitle())
  self.nametext = Text(name, "TextBold", 22)
  self.lifebar  = LifeBar(actor, 0, 48)
  self.stats    = Stats(actor, _MG*4/3, 112 + 192 + 2*_MG - 32, _INNERWIDTH)
  self.widgets  = Widgets(actor, _MG*4/3, 112 + 192 + 2*_MG + 16)
  self:addChild(self.lifebar)
  self:addChild(self.stats)
  self:addChild(self.widgets)
  self:setPosition(960 + _MG, _MG)
  return self:register("HUD_BG", nil, "actor_panel")
end

function ActorHudTree:getWidgets()
  return self.widgets
end

function ActorHudTree:render(g)
  g.setColor(1, 1, 1)
  g.setLineWidth(4)
  g.push()
  g.translate(-_MG, -_MG)
  g.line(0, 0, 0, 720)
  g.setColor(COLORS.DARKER)
  g.rectangle("fill", 0, 0, _WIDTH, _HEIGHT)
  g.pop()
  return self.nametext:draw(0, -8)
end

return ActorHudTree
