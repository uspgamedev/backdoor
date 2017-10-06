
local RES = require 'resources'

-- CONSTANTS -------------------------------------------------------------------

local _W, _H
local _ANGLE = math.pi/4
local _RADIUS = 196
local _ACTIONS = {
  'interact', 'playcard', 'drawhand', 'wait'
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
  _W, _H = love.graphics.getDimensions()

end

function ActionMenu:moveFocus(dir)
  if dir == "up" then
    self.current = math.max(1, self.current - 1)
  elseif dir == "down" then
    self.current = math.min(#_ACTIONS, self.current + 1)
  end
end

function ActionMenu:getSelected()
  return _ACTIONS[self.current]
end

function ActionMenu:show()
  --if self.fadeout then
  --  MAIN_TIMER:cancel(self.fadeout)
  --  self.fadeout = false
  --  self.invisible = true
  --end
  --if self.fadein or not self.invisible then
  --  return
  --end
  --self.selected = false
  --self.invisible = false
  --self.enter = self.enter or { 0 }
  --self.fadein = MAIN_TIMER:tween(
  --  0.5, self.enter, { 1 }, 'out-cubic',
  --  function ()
  --    self.fadein = false
  --  end
  --)
end

function ActionMenu:hide()
  --if self.fadein then
  --  MAIN_TIMER:cancel(self.fadein)
  --  self.fadein = false
  --end
  --if self.fadeout or self.invisible then
  --  return
  --end
  --self.enter = self.enter or { 1 }
  --self.fadeout = MAIN_TIMER:tween(
  --  0.5, self.enter, { 0 }, 'out-cubic',
  --  function ()
  --    self.fadeout = false
  --    self.invisible = true
  --  end
  --)
end

function ActionMenu:draw()
  local g = love.graphics
  local cos, sin, pi = math.cos, math.sin, math.pi
  g.push()
  g.translate(_W/2, _H/2 - 40)
  local rot = 0
  for i,action_name in ipairs(_ACTIONS) do
    local k = i - self.current
    g.push()
    local x,y = cos(rot - _ANGLE*k), -sin(rot - _ANGLE*k)
    g.translate(_RADIUS*x, _RADIUS*y)
    --if self.selected == i+1 then
    --  g.scale(1.5, 1.5)
    --end
    --rgb(229, 181, 59)
    local fade = (i == self.current) and 1 or 0.5
    g.setColor(80, 10, 50, fade*100)
    g.circle("fill", 8, 8, 64*fade)
    g.setColor(230, 180, 60, fade*255)
    g.circle("fill", 0, 0, 64*fade)
    g.setColor(255, 255, 255, 255)
    g.draw(RES.loadTexture('icon-' .. action_name), 0, 0, 0, 1/4*fade, 1/4*fade,
           256, 256)
    g.pop()
  end
  g.pop()
end

return ActionMenu

