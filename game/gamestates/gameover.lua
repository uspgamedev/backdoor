
local state = {}

function state:enter(from, player, views)
  self.player = player
  self.views = views
  print("YOU DIED YOU NOOB")
end

function state:leave()
end

function state:update(dt)
  return SWITCHER.pop()
end

function state:draw()
  Draw.allTables()
end

return state

