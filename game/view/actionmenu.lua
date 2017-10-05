
local RES = require 'resources'

-- CONSTANTS -------------------------------------------------------------------

local ANGLE = math.pi/6
local ACTIONS = {
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

  self.invisible = true
  self.current = 1

end

function ActionMenu:move(dir)
  if dir == "up" then
    self.current = math.max(1, self.current - 1)
  elseif dir == "down" then
    self.current = math.min(#ACTIONS, self.current + 1)
  end
end

function ActionMenu:getSelected()
  return ACTIONS[self.current]
end

function ActionMenu:show()
  self.invisible = false
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
  self.invisible = true
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
  local enter = 1 --self.enter[1]
  g.push()
  g.translate(W/2, H/2 - 20)
  local rot = ANGLE * (enter - 1) + ANGLE
  for i,action_name in ipairs(ACTIONS) do
    g.push()
    local x,y = cos(rot - ANGLE*i*2*pi), -sin(rot - ANGLE*i*2*pi)
    g.translate(128*x, 128*y)
    --if self.selected == i+1 then
    --  g.scale(1.5, 1.5)
    --end
    g.setColor(80, 10, 50, enter*100)
    g.circle("fill", 8, 8, 32)
    g.setColor(20, 100, 80, enter*255)
    g.circle("fill", 0, 0, 32)
    g.scale(1/16, 1/16)
    g.draw(RES.loadTexture(action_name), 16, 16)
    g.pop()
  end
  g.pop()
end

return ActionMenu

