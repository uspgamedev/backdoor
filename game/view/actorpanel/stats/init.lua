
local Node      = require 'view.node'
local Attribute = require 'view.actorpanel.stats.attribute'
local VIEWDEFS  = require 'view.definitions'
local DEFS      = require 'domain.definitions'

local Stats = Class({ __includes = { Node } })

function Stats:init(actor, x, y, width)
  Node.init(self)
  local margin = VIEWDEFS.PANEL_MG
  self.attrs = {}
  for i,attr_name in ipairs(DEFS.PRIMARY_ATTRIBUTES) do
    self.attrs[attr_name] = Attribute(actor, attr_name,
                                      (i-1) * (width/4 + margin/2), 0, width/4)
    self:addChild(self.attrs[attr_name])
  end
  self:setPosition(x, y)
end

function Stats:render(g)
end

return Stats

