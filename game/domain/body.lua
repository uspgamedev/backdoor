local Body = Class{
  __includes = { ELEMENT }
}

function Body:init(hp)

  ELEMENT.init(self)

  self.hp = hp

end

return Body
