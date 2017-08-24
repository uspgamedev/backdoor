
local GameElement = require 'domain.gameelement'

local Body = Class{
  __includes = { GameElement }
}

function Body:init(specname)

  GameElement.init(self, 'body', specname)

  self.damage = 0
  self.sector_id = nil

end

function Body:loadState(state)
  self.damage = state.damage
end

function Body:saveState()
  local state = {}
  state.damage = self.damage
  return state
end

function Body:setSector(sector_id)
  self.sector_id = sector_id
end

function Body:getSector()
  return Util.findId(self.sector_id)
end

function Body:getPos()
  return self:getSector():getBodyPos(self)
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

function Body:takeDamage(amount)
  self.damage = math.min(self:getMaxHP(), self.damage + amount)
end

return Body
