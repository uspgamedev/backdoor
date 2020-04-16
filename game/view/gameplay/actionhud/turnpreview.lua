
-- luacheck: globals love

local COLORS      = require 'domain.definitions.colors'
local FONT        = require 'view.helpers.font'
local Class       = require "steaming.extra_libs.hump.class"
local ELEMENT     = require "steaming.classes.primitives.element"

local TurnPreview = Class{
  __includes = { ELEMENT }
}

local _MAX_TURNS = 10

function TurnPreview:init(player)

  ELEMENT.init(self)

  self.player = player

  self.text_font = FONT.get("Text", 18)
  self.turns = nil

end

function TurnPreview:refresh()
  local seen = self.player:getVisibleBodies()
  local sector = self.player:getSector()
  if next(seen) then
    local turns = sector:previewTurns(_MAX_TURNS, function (actor)
      return actor == self.player or seen[actor:getBody():getId()]
    end)
    if #turns > 0 then
      self.turns = turns
    end
  else
    self.turns = nil
  end
end

function TurnPreview:draw()
  if self.turns then
    local g = love.graphics
    g.push()
    g.translate(32, 32)
    g.setColor(COLORS.DARKER)
    g.rectangle('fill', 0, 0, 128, 256)
    g.setColor(COLORS.NEUTRAL)
    g.setLineWidth(2)
    g.rectangle('line', 0, 0, 128, 256)
    self.text_font:set()
    g.translate(8, 4)
    for i, actor in ipairs(self.turns) do
      g.push()
      g.translate(0, (i - 1) * 24)
      local name = "player"
      if actor ~= self.player then
        name = actor:getSpecName() .. " " .. actor:getBody():getSpecName()
      end
      g.print(name, 0, 0)
      g.pop()
    end
    g.pop()
  end
end

return TurnPreview

