
local PlayerWinView   = require 'view.playerwin'
local Draw            = require "draw"
local SoundTrack      = require 'view.soundtrack'

local state = {}

local _soundtrack

function state:enter(from, player)

  self.view = PlayerWinView(player)
  self.view:register("HUD")

  _soundtrack = SoundTrack.get()
  _soundtrack:disableTrack("default")
  _soundtrack:disableTrack("danger")
end

function state:leave()
  _soundtrack:enableTrack("default")

  self.view:kill()
  self.view = nil
end

function state:update(dt)
  return self.view:isDone() and SWITCHER.pop()
end

function state:draw()
  Draw.allTables()
end

return state
