
local Node      = require 'view.node'
local Attribute = require 'view.actorpanel.stats.attribute'
local VIEWDEFS  = require 'view.definitions'
local COLORS    = require 'domain.definitions.colors'
local DEFS      = require 'domain.definitions'
local Text      = require 'view.helpers.text'
local Class     = require "steaming.extra_libs.hump.class"

local Stats = Class({ __includes = { Node } })

function Stats:init(actor, x, y, width)
  Node.init(self)
  self:setId('actorpanel-stats')
  local margin = VIEWDEFS.PANEL_MG
  self.actor = actor
  self.width = width
  self.attrs = {}
  for i,attr_name in ipairs(DEFS.PRIMARY_ATTRIBUTES) do
    self.attrs[attr_name] = Attribute(actor, attr_name,
                                      (i-1) * (width/4 + margin/2), 32, width/4)
    self:addChild(self.attrs[attr_name])
  end
  self.exp_preview = false
  self.exp_preview_text = Text("", "Text", 20, { color = COLORS.VALID,
                                                 dropshadow = true })
  self.exp_preview_offset = 0
  self:setPosition(x, y)
end

function Stats:setExpPreview(value)
  if value and value > 0 then
    self.exp_preview = true
    self.exp_preview_text:setText(("+%4d"):format(value))
    self.exp_preview_offset = -10
  else
    self.exp_preview = false
  end
end

function Stats:process(dt)
  local offset_speed = 120
  if self.exp_preview_offset < 0 then
    self.exp_preview_offset = math.min(0, self.exp_preview_offset +
                                          offset_speed*dt)
  end
  if self.exp_preview then
    self.exp_preview_text:setAlpha(1)
  else
    local alpha = self.exp_preview_text:getAlpha()
    self.exp_preview_text:setAlpha(alpha > 0.05 and alpha * 0.5 or 0)
  end
end

function Stats:render(g)
  -- exp
  g.push()
  g.setColor(COLORS.NEUTRAL)
  local text = ("EXP: %04d"):format(self.actor:getExp())
  g.print(text, 0, 0)
  local x = g.getFont():getWidth(text) - self.exp_preview_text:getTextWidth()
  self.exp_preview_text:draw(x, self.exp_preview_offset -
                                g.getFont():getHeight()/2 - 2)

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
