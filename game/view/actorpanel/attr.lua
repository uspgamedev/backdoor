
local Node  = require 'view.node'
local Class = require "steaming.extra_libs.hump.class"

local Attr = Class({ __includes = { Node } })

function Attr:init(actor)
  Node.init(self)
end

return Attr

