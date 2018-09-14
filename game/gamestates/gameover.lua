
local PlayerDeathView = require 'view.playerdeath'

local state = {}

function state:enter(from, player)
  self.view = PlayerDeathView(player)
  self.view:addElement("HUD")
  print("YOU DIED YOU NOOB")
end

function state:leave()
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

