
local Node = require 'view.node'

local Attr = Class({ __includes = { Node } })

function Attr:init(actor)
  Node.init(self)
end

return Attr

