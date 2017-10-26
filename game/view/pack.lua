
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

  self.actor = actor
  self.pack = {}

  self.is_locked = true --If pack view controls are locked

  for i,card_specname in actor:iteratePack() do
    table.insert(self.pack, Card(card_specname))
  end

  self.focus_index = math.ceil(#self.pack/2)  -- What card is focused

  --Graphic properties
  self.packview_x_offset = O_WIN_W --Offset on x value applied to all packview elements
  self.cards_y_offset = {} --Applied y offset on each card
  for i = 1, #self.pack do
    self.cards_y_offset[i] = 0
  end
  self.cards_alpha = {} --Alpha of each card (range [0,1])
  for i = 1, #self.pack do
    self.cards_alpha[i] = 1
  end
  self.info_elements_alpha = 0 --Alpha of other elements besides cards (range [0,256])

  --Start intro animation
  ELEMENT.addTimer(
    self, "start_animation", MAIN_TIMER, "tween", .6, self,
    {packview_x_offset = 0, info_elements_alpha = 256}, "in-out-quad",
   function()
     self.is_locked = false
   end)


  _font = _font or FONT.get(_F_NAME, _F_SIZE)

end

function PackView:getRemainingCards()
  local index_list = {}
  self:lock()
  self:addTimer("removing_info_elements",
                MAIN_TIMER,
                "tween",
                .05,
                self,
                {info_elements_alpha = 0},
                "in-linear"
  )

  for i = 1, #self.pack do
    table.insert(index_list,1)
    self:addTimer("getting_card_timer_"..i,
                  MAIN_TIMER,
                  "after",
                  (i-1)*.06,
                  function()
                    self:addTimer("getting_card_"..i,
                                  MAIN_TIMER,
                                  "tween",
                                  .4,
                                  self.cards_y_offset,
                                  {[i] = 500},
                                  "in-quad",
                                  function()
                                    if i == #self.pack then
                                      Signal.emit("end_pack_state")
                                    end
                                  end
                    )
                  end
    )
  end

  return index_list
end

function PackView:isEmpty()
  return #self.pack == 0
end

function PackView:lock()
  self.is_locked = true
end

function PackView:unlock()
  self.is_locked = false
end


function PackView:isLocked()
  return self.is_locked
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
  self:lock()
  self:addTimer("consuming_card_y_offset",
                MAIN_TIMER,
                "tween",
                .2,
                self.cards_y_offset,
                {[self.focus_index] = -30}
  )
  self:addTimer("consuming_card_alpha",
                MAIN_TIMER,
                "tween",
                .2,
                self.cards_alpha,
                {[self.focus_index] = 0},
                "in-linear",
                function()
                  table.remove(self.pack, self.focus_index)
                  self.focus_index = math.min(self.focus_index, #self.pack)
                  if #self.pack == 0 then
                    Signal.emit("end_pack_state")
                  else
                    self.cards_alpha[self.focus_index] = 1
                    self.cards_y_offset[self.focus_index] = 0
                    self:unlock()
                  end
                end
  )
end

function PackView:draw()
  local g = love.graphics

  --Draw all cards previous to focused card
  local alpha = 1
  local x = O_WIN_W/2 - 3*CARD.getWidth()/2 - 65  + self.packview_x_offset
  local y = O_WIN_H/2 - CARD.getHeight()/2 + 30
  for i = self.focus_index-1, 1, -1 do
    local card_gap = 30
    local card = self.pack[i]
    if card then
      CARD.draw(card, x, y + self.cards_y_offset[i], false, alpha)
    end
    x = x - card_gap - CARD.getWidth()
    alpha = math.max(0, alpha - .4)
  end

  --Draw current focused card
  local card = self.pack[self.focus_index]
  if card then

    --Draw consume text above indication arrow
    _font:set()
    local c = COLORS.NEUTRAL
    local info_elements_color = {c[1],c[2],c[3],self.info_elements_alpha}
    g.setColor(info_elements_color)
    local text_to_draw = "consume"
    x = O_WIN_W/2 - _font:getWidth(text_to_draw)/2  + self.packview_x_offset
    y = O_WIN_H/2 - CARD.getHeight()/2 - 50 - _font:getHeight(text_to_draw)
    g.print(text_to_draw, x, y)

    --Draw consume indication arrow
    g.setLineWidth(3)
    local t_size = 25
    x = O_WIN_W/2  + self.packview_x_offset
    y = O_WIN_H/2 - CARD.getHeight()/2 - 24
    g.polygon("line", x - t_size/2, y,
                      x + t_size/2, y,
                      x, y - t_size*math.sqrt(3)/2)


    --Draw card
    local x, y = O_WIN_W/2 - CARD.getWidth()/2  + self.packview_x_offset, O_WIN_H/2 - CARD.getHeight()/2
    CARD.draw(card, x, y + self.cards_y_offset[self.focus_index], false, self.cards_alpha[self.focus_index])

    --Draw pack info below card
    local info = ("[%d/%d]"):format(self.focus_index,
    #self.pack)
    x, y = O_WIN_W/2 - _font:getWidth(info)/2  + self.packview_x_offset, y + CARD.getHeight() + 20
    _font:set()
    g.setColor(info_elements_color)
    g.print(info, x, y)

    --Draw left arrow
    if self.focus_index > 1 then
      local t_size = 30
      x = O_WIN_W/2 - CARD.getWidth()/2 - 15  + self.packview_x_offset
      y = O_WIN_H/2
      g.polygon("line", x, y - t_size/2,
                        x, y + t_size/2,
                        x - t_size*math.sqrt(3)/2, y)
    end

    if self.focus_index < #self.pack then
      --Draw right arrow
      local t_size = 30
      x = O_WIN_W/2 + CARD.getWidth()/2 + 15  + self.packview_x_offset
      y = O_WIN_H/2
      g.polygon("line", x, y - t_size/2,
                        x, y + t_size/2,
                        x + t_size*math.sqrt(3)/2, y)
    end

  end

  --Draw all cards after focused card
  local alpha = 1
  local x = O_WIN_W/2 + CARD.getWidth()/2 + 65  + self.packview_x_offset
  local y = O_WIN_H/2 - CARD.getHeight()/2 + 30
  for i = self.focus_index+1, #self.pack do
    local card_gap = 30
    local card = self.pack[i]
    if card then
      CARD.draw(card, x, y  + self.cards_y_offset[i], false, alpha)
    end
    x = x + card_gap + CARD.getWidth()
    alpha = math.max(0, alpha - .4)
  end

end

return PackView
