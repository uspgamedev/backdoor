local GameElement = require 'domain.gameelement'

local Card = Class{
  __includes = { GameElement }
}

function Card:init(specname)

  GameElement.init(self, 'card', specname)

end

function Card:getName()
  return self:getSpec('name')
end

return Card
