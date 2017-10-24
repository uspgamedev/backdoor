
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
    table.insert(self.pack, Card(card_specname))
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

  --Draw all cards previous to focused card
  local alpha = 1
  local x = O_WIN_W/2 - 3*CARD.getWidth()/2 - 65
  local y = O_WIN_H/2 - CARD.getHeight()/2 + 30
  for i = self.focus_index-1, 1, -1 do
    local card_gap = 30
    local card = self.pack[i]
    if card then
      CARD.draw(card, x, y, false, alpha)
    end
    x = x - card_gap - CARD.getWidth()
    alpha = math.max(0, alpha - .4)
  end

  --Draw current focused card
  local card = self.pack[self.focus_index]
  if card then

    --Draw consume text above indication arrow
    _font:set()
    g.setColor(COLORS.NEUTRAL)
    local text_to_draw = "consume"
    x = O_WIN_W/2 - _font:getWidth(text_to_draw)/2
    y = O_WIN_H/2 - CARD.getHeight()/2 - 50 - _font:getHeight(text_to_draw)
    g.print(text_to_draw, x, y)

    --Draw consume indication arrow
    g.setLineWidth(3)
    local t_size = 25
    x = O_WIN_W/2
    y = O_WIN_H/2 - CARD.getHeight()/2 - 24
    g.polygon("line", x - t_size/2, y,
                      x + t_size/2, y,
                      x, y - t_size*math.sqrt(3)/2)


    --Draw card
    local x, y = O_WIN_W/2 - CARD.getWidth()/2, O_WIN_H/2 - CARD.getHeight()/2
    CARD.draw(card, x, y)

    --Draw pack info below card
    local info = ("[%d/%d]"):format(self.focus_index,
    #self.pack)
    x, y = O_WIN_W/2 - _font:getWidth(info)/2, y + CARD.getHeight() + 20
    _font:set()
    g.setColor(COLORS.NEUTRAL)
    g.print(info, x, y)

    --Draw left arrow
    if self.focus_index > 1 then
      local t_size = 30
      x = O_WIN_W/2 - CARD.getWidth()/2 - 15
      y = O_WIN_H/2
      g.polygon("line", x, y - t_size/2,
                        x, y + t_size/2,
                        x - t_size*math.sqrt(3)/2, y)
    end

    if self.focus_index < #self.pack then
      --Draw right arrow
      local t_size = 30
      x = O_WIN_W/2 + CARD.getWidth()/2 + 15
      y = O_WIN_H/2
      g.polygon("line", x, y - t_size/2,
                        x, y + t_size/2,
                        x + t_size*math.sqrt(3)/2, y)
    end

  end

  --Draw all cards after focused card
  local alpha = 1
  local x = O_WIN_W/2 + CARD.getWidth()/2 + 65
  local y = O_WIN_H/2 - CARD.getHeight()/2 + 30
  for i = self.focus_index+1, #self.pack do
    local card_gap = 30
    local card = self.pack[i]
    if card then
      CARD.draw(card, x, y, false, alpha)
    end
    x = x + card_gap + CARD.getWidth()
    alpha = math.max(0, alpha - .4)
  end

end

return PackView
