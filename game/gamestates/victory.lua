
--local VictoryView = require 'view.playerdeath'
local Draw = require "draw"

local state = {}

function state:enter(from, player)
  --self.view = PlayerDeathView(player)
  --self.view:register("HUD")
  print("YOU HAVE SAVED VANTHEN'EAH... FOR A FEW MORE GENERATIONS")
end

function state:leave()
  --self.view:kill()
  --self.view = nil
end

function state:update(dt)
  --return self.view:isDone() and SWITCHER.pop()
end

function state:draw()
  Draw.allTables()
end

return state
