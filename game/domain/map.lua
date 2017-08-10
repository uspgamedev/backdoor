local Map = Class {
  __includes = { ELEMENT }
}

function Map:init(w, h)

  ELEMENT.init(self)

  self.w = w
  self.h = h

  self.tiles = {}
  self.bodies = {}
  for i = 1, h do
    self.tiles[i] = {}
    self.bodies[i] = {}
    for j = 1, w do
      self.tiles[i][j] = {25, 73, 127}
      self.bodies[i][j] = false
    end
  end

end

function Map:putBody(i, j, body)
  assert(not self.bodies[i][j])
  self.bodies[i][j] = body
end

return Map
