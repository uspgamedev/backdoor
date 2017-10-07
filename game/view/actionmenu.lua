
local RES = require 'resources'

-- CONSTANTS -------------------------------------------------------------------

local _W, _H
local _ANGLE = math.pi/4
local _RADIUS = 196
local _ACTIONS = {
  'interact', 'primary', 'widget', 'playcard', 'drawhand', 'openpack', 'wait'
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
  self.tween = nil
  _W, _H = love.graphics.getDimensions()

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
    if self.tween then
      MAIN_TIMER:cancel(self.tween)
    end
    self.tween = MAIN_TIMER:tween(0.3, self, { switch = 0 }, 'out-back',
                                  function () self.tween = nil end)
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
end

function ActionMenu:close(after)
  MAIN_TIMER:tween(0.2, self, { enter = 0 }, 'out-circ', after)
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
    g.push()
    local x,y = cos(rot - _ANGLE*k), -sin(rot - _ANGLE*k)
    g.translate(_RADIUS*x, _RADIUS*y)
    local size = (i == self.current) and (1 - abs(switch)/2) or 0.5
    local fade = max(0, min(1, (3 - abs(k))/3))
    g.setColor(80, 10, 50, enter*fade*100)
    g.circle("fill", 8, 8, 64*size)
    g.setColor(230, 180, 60, enter*fade*255)
    g.circle("fill", 0, 0, 64*size)
    g.setColor(255, 255, 255, enter*fade*255)
    g.draw(RES.loadTexture('icon-' .. action_name), 0, 0, 0, 1/4*size, 1/4*size,
           256, 256)
    g.pop()
  end
  g.pop()
end

return ActionMenu

