
-- luacheck: globals love

local COLORS      = require 'domain.definitions.colors'
local FONT        = require 'view.helpers.font'
local Class       = require "steaming.extra_libs.hump.class"
local ELEMENT     = require "steaming.classes.primitives.element"
local vec2        = require 'cpml' .vec2

local TurnPreview = Class{
  __includes = { ELEMENT }
}

local _MAX_TURNS = 6

TurnPreview.WIDTH = 160

function TurnPreview:init(player, handview, x, y)

  ELEMENT.init(self)

  self.player = player
  self.handview = handview
  self.position = vec2(x, y)

  self.text_font = FONT.get("Text", 18)
  self.turns = nil

end

function TurnPreview:disable()
  self.turns = nil
end

function TurnPreview:refresh()
  local seen = self.player:getVisibleBodies()
  local sector = self.player:getSector()
  if next(seen) then
    local turns_full = sector:previewTurns(_MAX_TURNS, false, function (actor)
      return actor == self.player or seen[actor:getBody():getId()]
    end)
    local turns_halved = sector:previewTurns(_MAX_TURNS, true, function (actor)
      return actor == self.player or seen[actor:getBody():getId()]
    end)
    if #turns_full > 0 and #turns_halved > 0 then
      self.turns = { full = turns_full, halved = turns_halved }
    end
  else
    self.turns = nil
  end
end

function TurnPreview:draw()
  if self.turns then
    local g = love.graphics
    g.push()
    g.translate(self.position:unpack())
    g.setColor(COLORS.DARKER)
    local height = 12 + 24*_MAX_TURNS
    g.rectangle('fill', 0, 0, self.WIDTH, height)
    g.setColor(COLORS.NEUTRAL)
    g.setLineWidth(2)
    g.rectangle('line', 0, 0, self.WIDTH, height)
    self.text_font:set()
    g.translate(8, 4)
    local which = self:_is_halved() and 'halved' or 'full'
    for i, actor in ipairs(self.turns[which]) do
      g.push()
      g.translate(0, (i - 1) * 24)
      local name = "player"
      if actor ~= self.player then
        name = ("%s %s %s"):format(actor:getSpecName(),
                                   actor:getBody():getSpecName(),
                                   actor:getId())
      end
      g.print(name, 0, 0)
      g.pop()
      if actor == self.player then
        break
      end
    end
    g.pop()
  end
end

function TurnPreview:_is_halved()
  local focused_card = self.handview:getFocusedCard()
  focused_card = focused_card and focused_card.card
  return focused_card and focused_card:isHalfExhaustion()
end

return TurnPreview

