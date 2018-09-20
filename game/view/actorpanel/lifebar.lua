
local PPBar = require 'view.actorpanel.ppbar'

local LifeBar = Class({ __includes = { PPBar } })

function LifeBar:init(actor)
  PPBar.init(self, actor)
end

return LifeBar

