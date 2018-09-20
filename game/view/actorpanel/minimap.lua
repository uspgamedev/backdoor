
local Node = require 'view.node'

local MiniMap = Class({ __includes = { Node } })

function MiniMap:init(actor)
  Node.init(self)
end

return MiniMap

