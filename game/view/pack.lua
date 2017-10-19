
local DB     = require 'database'
local RES    = require 'resources'
local FONT   = require 'view.helpers.font'
local DEFS   = require 'domain.definitions'
local COLORS = require 'domain.definitions.colors'
local CARD   = require 'view.helpers.card'

local Card   = require 'domain.card'


--PackView Class--

local PackView = Class{
  __includes = { ELEMENT }
}

--CONSTS--
local _F_NAME = "Text" --Font name
local _F_SIZE = 24 --Font size


--LOCAL--
local _font

--CLASS FUNCTIONS--

function PackView:init(actor)

  ELEMENT.init(self)

  self.focus_index = 1  -- What card is focused
  self.actor = actor
  self.pack = {}

  for i,card_specname in actor:iteratePack() do
    table.insert(self.pack, {card = Card(card_specname), index = i})
  end

  _font = _font or FONT.get(_F_NAME, _F_SIZE)

end

function PackView:removeCurrent()
  table.remove(self.pack, self.focus_index)
  self.focus_index = math.min(self.focus_index, #self.pack)
end

function PackView:isEmpty()
  return #self.pack == 0
end

function PackView:getFocusedCardIndex()
  assert(self.focus_index >= 1 and self.focus_index <= #self.pack)
  return self.pack[self.focus_index].index
end

function PackView:getFocus()
  return self.focus_index
end

function PackView:moveFocus(dir)
  if dir == "left" then
    self.focus_index = math.max(1, self.focus_index - 1)
  elseif dir == "right" then
    self.focus_index = math.min(#self.pack, self.focus_index + 1)
  end
end

function PackView:consumeCard()
  self:removeCurrent()
end

function PackView:draw()
  local g = love.graphics
  local x, y = g.getWidth()/2, 400

  --Draw current focused card
  local card_data = self.pack[self.focus_index]
  if card_data then
    CARD.draw(card_data.card, x, y + 100)

    _font:set()
    g.setColor(COLORS.NEUTRAL)
    local info = ("[%d/%d]"):format(self.focus_index,
    #self.pack)
    g.print(info, x, y)
  end

end

return PackView
