
local GameElement = require 'domain.gameelement'

local Body = Class{
  __includes = { GameElement }
}

function Body:init(specname)

  GameElement.init(self, 'body', specname)

  self.damage = 0

end

function Body:loadState(state)
  self.damage = state.damage
end

function Body:saveState()
  local state = {}
  state.damage = self.damage
  return state
end

function Body:getHP()
  return self:getSpec('hp') - self.damage
end

return Body

