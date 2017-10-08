
local RES = require 'resources'
local FONT = require 'view.helpers.font'

-- CONSTANTS -------------------------------------------------------------------

local _W, _H
local _ANGLE = math.pi/4
local _RADIUS = 196
local _ACTIONS = {
  'interact', 'primary', 'widget', 'playcard', 'drawhand', 'openpack', 'wait',
  interact = "Interact",
  primary = "Primary Arte",
  widget = "Use Widget",
  playcard = "Play Card",
  drawhand = "Draw New Hand",
  openpack = "Open Card Pack",
  wait = "Wait"
}

-- LOCAL FUNCTION DECLARATIONS -------------------------------------------------

-- ActionMenu Class ----------------------------------------------------------

local ActionMenu = Class {
  __includes = { ELEMENT }
}

-- CLASS METHODS ---------------------------------------------------------------

function ActionMenu:init()

  ELEMENT.init(self)
  self.current = 1
  self.enter = 0
  self.switch = 0
  self.switch_tween = nil
  self.text = 0
  self.text_tween = nil
  _W, _H = love.graphics.getDimensions()

end

function ActionMenu:showLabel()
  local len = #_ACTIONS[_ACTIONS[self.current]]
  self.text = 0
  if self.text_tween then
    MAIN_TIMER:cancel(self.text_tween)
  end
  self.text_tween = MAIN_TIMER:tween(
    0.03 * len, self, { text = len+1 }, 'linear',
    function () self.text_tween = nil end
  )
end

function ActionMenu:hideLabel()
  if self.text_tween then
    MAIN_TIMER:cancel(self.text_tween)
  end
  self.text_tween = MAIN_TIMER:tween(
    0.01 * self.text, self, { text = 0 }, 'linear',
    function () self.text_tween = nil end
  )
end

function ActionMenu:moveFocus(dir)
  local last = self.current
  if dir == 'up' or dir == 'right' then
    self.current = math.max(1, self.current - 1)
  elseif dir == 'down' or dir == 'left' then
    self.current = math.min(#_ACTIONS, self.current + 1)
  end
  if last ~= self.current then
    self.switch = last - self.current
    if self.switch_tween then
      MAIN_TIMER:cancel(self.switch_tween)
    end
    self.switch_tween = MAIN_TIMER:tween(
      0.3, self, { switch = 0 }, 'out-back',
      function () self.switch_tween = nil end
    )
    self:showLabel()
  end
end

function ActionMenu:getCurrentFocus()
  return self.current
end

function ActionMenu:getSelected()
  return _ACTIONS[self.current]
end

function ActionMenu:open(last_focus, after)
  self.current = last_focus or self.current
  MAIN_TIMER:tween(0.2, self, { enter = 1 }, 'out-circ', after)
  self:showLabel()
end

function ActionMenu:close(after)
  MAIN_TIMER:tween(0.2, self, { enter = 0 }, 'out-circ', after)
  self:hideLabel()
end

function ActionMenu:draw()
  local g = love.graphics
  local enter = self.enter
  local switch = self.switch
  local cos, sin, pi = math.cos, math.sin, math.pi
  local min, max, abs = math.min, math.max, math.abs
  CAM:zoomTo(1 + enter)
  g.push()
  g.translate(_W/2, _H/2 - 40)
  local rot = (enter - 1) * pi + switch * _ANGLE
  for i,action_name in ipairs(_ACTIONS) do
    local k = i - self.current
    local angle = rot - _ANGLE*k
    local x,y = cos(angle), -sin(angle)
    local size = (i == self.current) and (1 - abs(switch)/2) or 0.5
    local fade = max(0, min(1, 1 - abs(angle)/(pi*0.6)))
    g.push()
    g.translate(_RADIUS*x, _RADIUS*y)
    g.setColor(80, 10, 50, enter*fade*100)
    g.circle("fill", 8, 8, 64*size)
    g.setColor(230, 180, 60, enter*fade*255)
    g.circle("fill", 0, 0, 64*size)
    g.setColor(255, 255, 255, enter*fade*255)
    g.draw(RES.loadTexture('icon-' .. action_name), 0, 0, 0, 1/4*size, 1/4*size,
           256, 256)
    g.pop()
  end
  g.push()
  FONT.set('Text', 32)
  g.translate(_RADIUS, 0)
  g.setColor(255, 255, 255, 255)
  local label = _ACTIONS[_ACTIONS[self.current]]
  g.print(label:sub(1, self.text), 64, 64)
  g.pop()
  g.pop()
end

return ActionMenu

