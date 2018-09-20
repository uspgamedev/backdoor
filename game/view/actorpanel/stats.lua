
local Node = require 'view.node'

local Stats = Class({ __includes = { Node } })

function Stats:init(actor)
  Node.init(self)
end

return Stats

