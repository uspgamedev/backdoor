local MapView = Class {
  __includes = { ELEMENT }
}

function MapView:init(map)

  ELEMENT.init(self)

  self.map = map

end

function MapView:setMap(map)
  self.map = map
end

function MapView:draw()

  for i = 0, self.map.h-1 do
    for j = 0, self.map.w-1 do
      love.graphics.setColor(125,75,25)
      love.graphics.rectangle("fill", j*80, i*80, 80, 80)
    end
  end

end

return MapView
