
local Node = require 'view.node'

local Widgets = Class({ __includes = { Node } })

function Widgets:init(actor)
  Node.init(self)
end

return Widgets

