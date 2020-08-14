
local Class = require "steaming.extra_libs.hump.class"
local SectorView  = require 'view.sector'
local AnimationPlayer  = require 'view.helpers.animationplayer'
local BufferView  = require 'view.gameplay.actionhud.buffer'
local ActorView   = require 'view.actorpanel'
local Announcement = require 'view.announcement'
local ActionHUD   = require 'view.gameplay.actionhud'

local GameplayView = Class {}

function GameplayView:setup(route)

  self.route = route

  -- sector view
  self.sector = SectorView(route)
  self.sector:register("L1", nil, "sector_view")
  self.sector:lookAt(route:getControlledActor())

  -- actor HUD
  self.action_hud = ActionHUD(route)
  self.action_hud:register(nil, 'task', ActionHUD.ID)

  -- buffer views
  self.frontbuffer = BufferView.newFrontBufferView(route)
  self.frontbuffer:register("HUD_BG", nil, "frontbuffer_view")
  self.backbuffer = BufferView.newBackBufferView(route)
  self.backbuffer:register("HUD_BG", nil, "backbuffer_view")

  -- actor view
  self.actor = ActorView(route:getPlayerActor())

  -- announcement box
  self.announcement = Announcement()
  self.announcement:register("HUD", nil, "announcement")

  self.animation_player = AnimationPlayer(self)

end

function GameplayView:destroy()
  self.sector:destroy()
  self.action_hud:destroy()
  self.frontbuffer:destroy()
  self.backbuffer:destroy()
  self.actor:destroy()
  self.announcement:destroy()
end

return GameplayView
