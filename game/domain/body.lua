
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
  return self:getMaxHP() - self.damage
end

function Body:getMaxHP()
  return self:getSpec('hp')
end

function Body:setHP(hp)
  self.damage = math.max(0, math.min(self:getMaxHP() - hp, self:getMaxHP()))
end

return Body

