

local AI = {}

local actors = {}

function AI.clear()
  actors = {}
end

function AI.addActor(actor, behavior)
  actors[actor] = require('domain.behaviors.' .. behavior)
end

function AI.processActors(map)
  for actor,behavior in pairs(actors) do
    actor:setAction(behavior(map, actor))
  end
end

return AI
