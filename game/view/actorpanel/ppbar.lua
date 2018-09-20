
local Node = require 'view.node'

local PPBar = Class({ __includes = { Node } })

function PPBar:init(actor)
  Node.init(self)
end

return PPBar

