local Map = Class {
  __includes = { ELEMENT }
}

function Map:init(w, h)

  ELEMENT.init(self)

  self.w = w
  self.h = h

end

return Map
