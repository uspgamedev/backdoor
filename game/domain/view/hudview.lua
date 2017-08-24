
local HudView = Class{
  __includes = { ELEMENT }
}

function HudView:init()
  ELEMENT.init(self)

  self.queue = {}
  self.size = 0
  self.x, self.y = 0, 0

end

function HudView:setPos (x, y)
  self.x, self.y = x, y
end

function HudView:push(draw_instruction)
  self.size = self.size + 1
  self.queue[self.size] = draw_instruction
end

function HudView:clear()
  for i = 1, self.size do
    self.queue[i] = nil
  end
  self.size = 0
end

function HudView:draw()
  local g = love.graphics
  g.push()
  for i = 1, self.size do
    print(unpack(self.queue[i]))
    g[self.queue[i][1]](unpack(self.queue[i], 2))
  end
  g.pop()
  self:clear()
end

return HudView
