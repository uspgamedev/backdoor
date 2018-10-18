
local Node      = require 'view.node'
local Attribute = require 'view.actorpanel.stats.attribute'
local VIEWDEFS  = require 'view.definitions'
local COLORS    = require 'domain.definitions.colors'
local DEFS      = require 'domain.definitions'
local Text      = require 'view.helpers.text'

local Stats = Class({ __includes = { Node } })

function Stats:init(actor, x, y, width)
  Node.init(self)
  local margin = VIEWDEFS.PANEL_MG
  self.actor = actor
  self.width = width
  self.attrs = {}
  for i,attr_name in ipairs(DEFS.PRIMARY_ATTRIBUTES) do
    self.attrs[attr_name] = Attribute(actor, attr_name,
                                      (i-1) * (width/4 + margin/2), 32, width/4)
    self:addChild(self.attrs[attr_name])
  end
  --self.exp_text = Text("", )
  self:setPosition(x, y)
end

function Stats:render(g)
  -- exp
  g.push()
  g.setColor(COLORS.NEUTRAL)
  g.print(("EXP: %04d"):format(self.actor:getExp()), 0, 0)

  -- packs
  local packcount = self.actor:getPrizePackCount()
  local packcolor = packcount > 0 and COLORS.VALID or COLORS.NEUTRAL
  local packstr = {
    COLORS.NEUTRAL, "PACKS: ",
    packcolor, ("%02d"):format(packcount)
  }
  g.translate(self.width/2 - 24, 0)
  g.setColor(COLORS.NEUTRAL)
  g.print(packstr, 0, 0)
  g.pop()
end

return Stats

