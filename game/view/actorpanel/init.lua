
-- luacheck: globals MAIN_TIMER

local COLORS = require 'domain.definitions.colors'

local Node      = require 'view.node'
local Text      = require 'view.helpers.text'
local VIEWDEFS  = require 'view.definitions'
local Class     = require "steaming.extra_libs.hump.class"

local Stats   = require 'view.actorpanel.stats'

local Deferred = require 'common.deferred'

local ActorHUDTree = Class({ __includes = { Node } })

local _WIDTH, _HEIGHT = VIEWDEFS.PANEL_W, VIEWDEFS.PANEL_H
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
  self.stats    = Stats(actor, _MG*4/3, _MG + _PD, _INNERWIDTH)
  self:addChild(self.stats)
  self:setPosition(ActorHUDTree.HIDDEN_POSITION())
  return self:register("HUD_BG", nil, "actor_panel")
end

function ActorHUDTree.HIDDEN_POSITION()
  local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  return w + 2*_MG, (h - _HEIGHT) / 2 + _MG
end

function ActorHUDTree.VISIBLE_POSITION()
  local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  return w - _WIDTH + _MG, (h - _HEIGHT) / 2 + _MG
end

function ActorHUDTree:getWidgets()
  return self.widgets
end

function ActorHUDTree:hide()
  if self:getTimer("timed_hide", MAIN_TIMER) then
    return
  end
  return self:_slideTo(ActorHUDTree.HIDDEN_POSITION())
end

function ActorHUDTree:timedHide(t)
  self:addTimer("timed_hide", MAIN_TIMER, "after", t,
                function()
                  self:removeTimer("timed_hide", MAIN_TIMER)
                  return self:_slideTo(ActorHUDTree.HIDDEN_POSITION())
                end)
end

function ActorHUDTree:show()
  self:removeTimer("timed_hide", MAIN_TIMER)
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
  g.rectangle("line", 0, 0, _WIDTH, _HEIGHT)
  g.setColor(COLORS.DARKER)
  g.rectangle("fill", 0, 0, _WIDTH, _HEIGHT)
  g.pop()
  return self.nametext:draw(0, -8)
end

return ActorHUDTree
