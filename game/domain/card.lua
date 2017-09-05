
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

function Card:isArt()
  return self:getSpec('type') == "ART"
end

function Card:getArtAction()
  return self:getSpec('art_action')
end

return Card

