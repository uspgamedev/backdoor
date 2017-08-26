

local DB = require 'database'

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

function GameElement:getSpec(key)
  return DB.loadSpec(self.spectype, self.specname)[key]
end

return GameElement

