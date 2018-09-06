
local state = {}

function state:enter(from, player, views)
  self.player = route.getControlledActor()
  self.views = views
end

function state:leave()
end

function state:update(dt)
end

function state:draw()
end

return state

