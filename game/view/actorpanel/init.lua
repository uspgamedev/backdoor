
local COLORS = require 'domain.definitions.colors'

local Node = require 'view.node'
local Text = require 'view.helpers.text'

local LifeBar = require 'view.actorpanel.lifebar'
local PPBar   = require 'view.actorpanel.ppbar'
local MiniMap = require 'view.actorpanel.minimap'
local Stats   = require 'view.actorpanel.stats'
local Widgets = require 'view.actorpanel.widgets'

local ActorHudTree = Class({ __includes = { Node } })

local _WIDTH, _HEIGHT = 320, 720
local _MG = 24

function ActorHudTree:init(actor)
  Node.init(self)
  self.actor = actor
  -- subtrees for each section
  local route = actor:getBody():getSector():getRoute()
  local name = ("%s the %s"):format(route.getPlayerName(), actor:getTitle())
  self.nametext = Text(name, "TextBold", 22)
  self.lifebar  = LifeBar(actor, 0, 48)
  self.ppbar    = PPBar(actor, 0, 48+32)
  self.minimap  = MiniMap(actor, 0, 112)
  self.stats    = Stats(actor)
  self.widgets  = Widgets(actor)
  self:addChild(self.lifebar)
  self:addChild(self.ppbar)
  self:addChild(self.minimap)
  self:addChild(self.stats)
  self:addChild(self.widgets)
  self:setPosition(960 + _MG, _MG)
  return self:addElement("HUD", "ActorHud")
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

