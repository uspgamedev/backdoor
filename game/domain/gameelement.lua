local Class   = require "steaming.extra_libs.hump.class"
local DB      = require 'database'
local ELEMENT = require "steaming.classes.primitives.element"

local GameElement = Class{
  __includes = { ELEMENT }
}

function GameElement:init(spectype, specname)

  ELEMENT.init(self)

  self.spectype = spectype
  self.specname = specname

end

function GameElement:kill()
  self.death = true
end

function GameElement:getId()
  return self.id
end

function GameElement:loadState(state)
end

function GameElement:saveState()
  local state = {}
  state.specname = self.specname
  return state
end

function GameElement:getSpecName()
  return self.specname
end

function GameElement:getSpec(key)
  local spec = DB.loadSpec(self.spectype, self.specname)
  assert(spec, ("Spec %s/%s not found"):format(self.spectype, self.specname))
  return spec[key]
end

return GameElement
