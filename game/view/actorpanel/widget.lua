
local Node = require 'view.node'

local Widget = Class({ __includes = { Node } })

function Widget:init(actor)
  Node.init(self)
end

return Widget

