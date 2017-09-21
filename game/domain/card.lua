
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
  return not not self:getSpec('art')
end

function Card:isUpgrade()
  return not not self:getSpec('upgrade')
end

function Card:getArtAction()
  return self:getSpec('art').art_action
end

function Card:getUpgradesList()
  return self:getSpec('upgrade').list
end

return Card

