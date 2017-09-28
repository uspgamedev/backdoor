
local RES = require 'resources'
local DIR = require 'domain.definitions.dir'

--BufferPickerView Class--

local BufferPickerView = Class {
  __includes = { ELEMENT }
}

--CONSTS--

local _font = function () return RES.loadFont("Text", 24) end

--LOCAL FUNCTIOKNS DECLARATIONS--

local expandArrows
local closeArrows

--CLASS FUNCTIONS--

function BufferPickerView:init(actor)

  ELEMENT.init(self)

  self.actor = actor
  self.select = 1
  self.secondary_select = nil

  --Variables for changing-buffer effect
  self.is_changing_buffer = false
  self.current_buffer_x_mod = 0
  self.current_buffer_a = 255
  self.secondary_buffer_x_mod = 0
  self.secondary_buffer_a = 0

  --Arrows
  self.right_arrow_x = O_WIN_W/2 + 120 - _font():getWidth(">")
  self.left_arrow_x = O_WIN_W/2 - 80
  self.arrows_y = 3*O_WIN_H/4 + _font():getHeight()/2

  expandArrows(self)

end

function BufferPickerView:draw()
  local c_x, c_y = O_WIN_W/2, O_WIN_H/2 --Center of screen position
  local g = love.graphics
  local w,h = 128,128
  local size = self.actor:getBufferSize(self.select)

  --Draw current selected buffer
  local img = IMG.CARD_BACK_1
  local i_w, i_h = img:getWidth(), img:getHeight() -- Image width and height
  local i_s = 1 --Image scale
  local i_x, i_y = c_x-i_w/2*i_s + self.current_buffer_x_mod, c_y-i_h/2*i_s --Image position
  local i_r = 0 --Image rotation
  g.setColor(255, 255, 255, self.current_buffer_a)
  for i = 1, math.ceil(size/2) do
    g.draw(img, i_x, i_y, i_r, i_s) --Draw image
    i_x, i_y = i_x + 10, i_y - 10
  end

  --Draw secondary selected buffer that's is fading away
  if self.is_changing_buffer then
    local size = self.actor:getBufferSize(self.secondary_select)
    local img = IMG.CARD_BACK_1
    local i_w, i_h = img:getWidth(), img:getHeight() -- Image width and height
    local i_s = 1 --Image scale
    local i_x, i_y = c_x-i_w/2*i_s + self.secondary_buffer_x_mod, c_y-i_h/2*i_s --Image position
    local i_r = 0 --Image rotation
    g.setColor(255, 255, 255, self.secondary_buffer_a)
    for i = 1, math.ceil(size/2) do
      g.draw(img, i_x, i_y, i_r, i_s) --Draw image
      i_x, i_y = i_x + 10, i_y - 10
    end
  end

  --Draw current buffer number and remaining cards
  g.setColor(255, 255, 200)
  g.setFont(_font())
  local back_buffer_size = self.actor:getBackBufferSize(self.select)
  g.printf(("%d (%2d) [%d]"):format(self.select, size, back_buffer_size),
           c_x-80, c_y + i_h/2 + 40, 200, "center")

  --Draw arrows
  g.setColor(239, 40, 103)
  g.setFont(_font())
  g.print(">", self.right_arrow_x, self.arrows_y)
  g.print("<", self.left_arrow_x, self.arrows_y)

end

function BufferPickerView:moveSelection(dir)
  local x_mod_value = 400
  local r_mod_value = 400

  local n = #self.actor.buffers
  if dir == 'left' then
    self.secondary_select = self.select
    self.select = (self.select - 2)%n + 1

    --Create changing-buffer effect
    self.is_changing_buffer = true
    self:removeTimer("change_buffer", MAIN_TIMER)
    self.current_buffer_a, self.secondary_buffer_a = 0, 255
    self.current_buffer_x_mod, self.secondary_buffer_x_mod = x_mod_value, 0
    self:addTimer("change_buffer", MAIN_TIMER, "tween",
                                                    .2,
                                                    self,
                                                    {current_buffer_a = 255,
                                                     secondary_buffer_a = 0,
                                                     current_buffer_x_mod = 0,
                                                     secondary_buffer_x_mod = -x_mod_value},
                                                     'out-quad',
                                                      function()
                                                        self.is_changing_buffer = false
                                                      end)
  elseif dir == 'right' then
    self.secondary_select = self.select
    self.select = self.select%n + 1

    --Create changing-buffer effect
    self.is_changing_buffer = true
    self:removeTimer("change_buffer", MAIN_TIMER)
    self.current_buffer_a, self.secondary_buffer_a = 0, 255
    self.current_buffer_x_mod, self.secondary_buffer_x_mod = -x_mod_value, 0
    self:addTimer("change_buffer", MAIN_TIMER, "tween",
                                                    .2,
                                                    self,
                                                    {current_buffer_a = 255,
                                                     secondary_buffer_a = 0,
                                                     current_buffer_x_mod = 0,
                                                     secondary_buffer_x_mod = x_mod_value},
                                                     'out-quad',
                                                      function()
                                                        self.is_changing_buffer = false
                                                      end)
  else
    error(("Invalid direction %s!"):format(dir))
  end
end

function BufferPickerView:getSelection()
  return self.select
end

--LOCAL FUNCTIONS--

function expandArrows(b)
  local mod_value = 10

  b:addTimer("arrow_effect", MAIN_TIMER, "tween",
                                              .5,
                                              b,
                                              {left_arrow_x = b.left_arrow_x - mod_value,
                                               right_arrow_x = b.right_arrow_x + mod_value},
                                              'in-linear',
                                               function()
                                                 closeArrows(b)
                                               end)
end

function closeArrows(b)
  local mod_value = 10

  b:addTimer("arrow_effect", MAIN_TIMER, "tween",
                                              .5,
                                              b,
                                              {left_arrow_x = b.left_arrow_x + mod_value,
                                               right_arrow_x = b.right_arrow_x - mod_value},
                                              'in-linear',
                                               function()
                                                 expandArrows(b)
                                               end)

end

return BufferPickerView
