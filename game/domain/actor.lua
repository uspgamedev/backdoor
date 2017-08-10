local Actor = Class{
  __includes = { ELEMENT }
}

function Actor:init(body)

  ELEMENT.init(self)

  self.body = body

end

return Actor
