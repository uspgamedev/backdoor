
local DIR = require 'domain.definitions.dir'

--BufferPickerView Class--

local BufferPickerView = Class {
  __includes = { ELEMENT }
}

--CLASS FUNCTIONS--

function BufferPickerView:init(actor)

  ELEMENT.init(self)

  self.actor = actor
  self.select = 1

end

function BufferPickerView:draw()
  local c_x, c_y = O_WIN_W/2, O_WIN_H/2 --Center of screen position
  local g = love.graphics
  local w,h = 128,128
  local size = self.actor:getBufferSize(self.select)
  local img = IMG.CARD_BACK_1
  local i_w, i_h = img:getWidth(), img:getHeight() -- Image width and height
  local i_s = 1 --Image scale
  local i_x, i_y = c_x-i_w/2*i_s, c_y-i_h/2*i_s --Image position
  local i_r = 0 --Image rotation
  g.setColor(255, 255, 255)
  for i = 1, math.floor(size/2) do
    g.draw(img, i_x, i_y, i_r, i_s) --Draw image
    i_x, i_y = i_x + 10, i_y - 10
  end

  --Draw buffer number and remaining cards
  g.setColor(255, 255, 200)
  g.print(("%d (%2d)"):format(self.select, size), c_x, c_y + i_h/2 + 40)
end

function BufferPickerView:moveSelection(dir)
  local n = #self.actor.buffers
  if dir == 'left' then
    self.select = (self.select - 2)%n + 1
  elseif dir == 'right' then
    self.select = self.select%n + 1
  else
    error(("Invalid direction %s!"):format(dir))
  end
end

function BufferPickerView:getSelection()
  return self.select
end

return BufferPickerView
