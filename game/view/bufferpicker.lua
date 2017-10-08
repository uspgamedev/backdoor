
local RES = require 'resources'
local FONT = require 'view.helpers.font'
local DIR = require 'domain.definitions.dir'

--BufferPickerView Class--

local BufferPickerView = Class {
  __includes = { ELEMENT }
}

--CONSTS--
local _F_NAME = "Text" --Font name
local _F_SIZE = 24 --Font size
local _BUFFER_TEXTURE = function () return RES.loadTexture("buffer-card") end

--LOCAL FUNCTIOKNS DECLARATIONS--

local _expandArrows
local _closeArrows

--LOCAL VARIABLES--

local _font

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

  --Init font
  _font = _font or FONT.get(_F_NAME, _F_SIZE)

  --Arrows
  self.right_arrow_x = O_WIN_W/2 + 120 - _font.getWidth(">")
  self.left_arrow_x = O_WIN_W/2 - 80
  self.arrows_y = 3*O_WIN_H/4 + _font.getHeight()/2

  _expandArrows(self)

end

function BufferPickerView:draw()
  local c_x, c_y = O_WIN_W/2, O_WIN_H/2 --Center of screen position
  local g = love.graphics
  local w,h = 128,128
  local size = self.actor:getBufferSize(self.select)

  --Draw current selected buffer
  local i_w, i_h = _BUFFER_TEXTURE():getWidth(), _BUFFER_TEXTURE():getHeight() -- Image width and height
  local i_s = 1 --Image scale
  local i_x, i_y = c_x-i_w/2*i_s + self.current_buffer_x_mod, c_y-i_h/2*i_s --Image position
  local i_r = 0 --Image rotation
  g.setColor(255, 255, 255, self.current_buffer_a)
  for i = 1, math.ceil(size/2) do
    g.draw(_BUFFER_TEXTURE(), i_x, i_y, i_r, i_s) --Draw image
    i_x, i_y = i_x + 10, i_y - 10
  end

  --Draw secondary selected buffer that's is fading away
  if self.is_changing_buffer then
    local size = self.actor:getBufferSize(self.secondary_select)
    local i_w, i_h = _BUFFER_TEXTURE():getWidth(), _BUFFER_TEXTURE():getHeight() -- Image width and height
    local i_s = 1 --Image scale
    local i_x, i_y = c_x-i_w/2*i_s + self.secondary_buffer_x_mod, c_y-i_h/2*i_s --Image position
    local i_r = 0 --Image rotation
    g.setColor(255, 255, 255, self.secondary_buffer_a)
    for i = 1, math.ceil(size/2) do
      g.draw(_BUFFER_TEXTURE(), i_x, i_y, i_r, i_s) --Draw image
      i_x, i_y = i_x + 10, i_y - 10
    end
  end

  --Draw current buffer number and remaining cards
  g.setColor(255, 255, 200)
  _font.set()
  local back_buffer_size = self.actor:getBackBufferSize(self.select)
  g.printf(("%d (%2d) [%d]"):format(self.select, size, back_buffer_size),
           c_x-80, c_y + i_h/2 + 40, 200, "center")

  --Draw arrows
  g.setColor(239, 40, 103)
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
  elseif dir == 'right' then
    self.secondary_select = self.select
    self.select = self.select%n + 1

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
  else
    error(("Invalid direction %s!"):format(dir))
  end
end

function BufferPickerView:getSelection()
  return self.select
end

--LOCAL FUNCTIONS--

function _expandArrows(b)
  local mod_value = 10

  b:addTimer("arrow_effect", MAIN_TIMER, "tween",
                                              .5,
                                              b,
                                              {left_arrow_x = b.left_arrow_x - mod_value,
                                               right_arrow_x = b.right_arrow_x + mod_value},
                                              'in-linear',
                                               function()
                                                 _closeArrows(b)
                                               end)
end

function _closeArrows(b)
  local mod_value = 10

  b:addTimer("arrow_effect", MAIN_TIMER, "tween",
                                              .5,
                                              b,
                                              {left_arrow_x = b.left_arrow_x + mod_value,
                                               right_arrow_x = b.right_arrow_x - mod_value},
                                              'in-linear',
                                               function()
                                                 _expandArrows(b)
                                               end)

end

return BufferPickerView
