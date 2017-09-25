
-- CONSTANTS -------------------------------------------------------------------

local W, H

-- LOCAL FUNCTION DECLARATIONS -------------------------------------------------

-- WidgetView Class ------------------------------------------------------------

local WidgetView = Class {
  __includes = { ELEMENT }
}

-- CLASS METHODS ---------------------------------------------------------------

function WidgetView:init(route)

  ELEMENT.init(self)

  W,H = love.graphics.getDimensions()

  self.route = route
  self.invisible = true

end

function WidgetView:select(idx)
  self.selected = idx
end

function WidgetView:getSelected()
  return self.selected
end

function WidgetView:show()
  if self.fadeout then
    MAIN_TIMER:cancel(self.fadeout)
    self.fadeout = false
    self.invisible = true
  end
  if self.fadein or not self.invisible then
    return
  end
  self.selected = false
  self.invisible = false
  self.enter = self.enter or { 0 }
  self.fadein = MAIN_TIMER:tween(
    0.5, self.enter, { 1 }, 'out-cubic',
    function ()
      self.fadein = false
    end
  )
end

function WidgetView:hide()
  if self.fadein then
    MAIN_TIMER:cancel(self.fadein)
    self.fadein = false
  end
  if self.fadeout or self.invisible then
    return
  end
  self.enter = self.enter or { 1 }
  self.fadeout = MAIN_TIMER:tween(
    0.5, self.enter, { 0 }, 'out-cubic',
    function ()
      self.fadeout = false
      self.invisible = true
    end
  )
end

function WidgetView:draw()
  local g = love.graphics
  local cos, sin, pi = math.cos, math.sin, math.pi
  local enter = self.enter[1]
  g.push()
  g.translate(W/2, H/2 - 20)
  local rot = pi/2 * (enter - 1) + pi/2
  for i=0,3 do
    g.push()
    local x,y = cos(rot - i/4*2*pi), -sin(rot - i/4*2*pi)
    g.translate(128*x, 128*y)
    if self.selected == i+1 then
      g.scale(1.5, 1.5)
    end
    g.setColor(80, 10, 50, enter*100)
    g.circle("fill", 8, 8, 32)
    g.setColor(20, 100, 80, enter*255)
    g.circle("fill", 0, 0, 32)
    g.pop()
  end
  g.pop()
end

return WidgetView

