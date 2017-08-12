
local DB = require 'database'

local Body = Class{
  __includes = { ELEMENT }
}

function Body:init(specname)

  ELEMENT.init(self)

  self.specname = specname
  self.spec = DB.bodyspecs[specname]
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
  return self.spec.hp - self.damage
end

return Body

