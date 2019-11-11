
-- luacheck: globals MAIN_TIMER

local COLORS = require 'domain.definitions.colors'

local Node      = require 'view.node'
local Text      = require 'view.helpers.text'
local VIEWDEFS  = require 'view.definitions'
local Class     = require "steaming.extra_libs.hump.class"

local LifeBar = require 'view.actorpanel.lifebar'
local Stats   = require 'view.actorpanel.stats'
local Widgets = require 'view.actorpanel.widgets'

local Deferred = require 'common.deferred'

local ActorHUDTree = Class({ __includes = { Node } })

local _WIDTH, _HEIGHT = 320, 720
local _MG = VIEWDEFS.PANEL_MG
local _PD = 8
local _INNERWIDTH = _WIDTH - 2*_PD - 2*_MG

function ActorHUDTree:init(actor)
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
  self:setPosition(ActorHUDTree.HIDDEN_POSITION())
  return self:register("HUD_BG", nil, "actor_panel")
end

function ActorHUDTree.HIDDEN_POSITION()
  local w, _ = VIEWDEFS.VIEWPORT_DIMENSIONS()
  return w + 2*_MG, _MG
end

function ActorHUDTree.VISIBLE_POSITION()
  local w, _ = VIEWDEFS.VIEWPORT_DIMENSIONS()
  return w - _WIDTH + _MG, _MG
end

function ActorHUDTree:getWidgets()
  return self.widgets
end

function ActorHUDTree:hide()
  return self:_slideTo(ActorHUDTree.HIDDEN_POSITION())
end

function ActorHUDTree:show()
  return self:_slideTo(ActorHUDTree.VISIBLE_POSITION())
end

function ActorHUDTree:_slideTo(x, y)
  local deferred = Deferred:new()
  self:removeTimer("slide_sidebar", MAIN_TIMER)
  self:addTimer("slide_sidebar", MAIN_TIMER, "tween", .5, self.position,
                 { x = x, y = y }, 'out-cubic', function () deferred:andThen() end)
  return deferred
end

function ActorHUDTree:render(g)
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

return ActorHUDTree
