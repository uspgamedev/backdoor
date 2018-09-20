
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
  self.nametext = Text(actor:getTitle(), "TextBold", 20)
  self.lifebar  = LifeBar(actor)
  self.ppbar    = PPBar(actor)
  self.minimap  = MiniMap(actor)
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
  g.setLineWidth(2)
  g.push()
  g.translate(-_MG, -_MG)
  g.line(0, 0, 0, 720)
  g.setColor(0.1, 0.1, 0.1)
  g.rectangle("fill", 0, 0, _WIDTH, _HEIGHT)
  g.pop()
  return self.nametext:draw(_MG, _MG)
end

return ActorHudTree

