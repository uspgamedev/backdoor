
local Actor = Class{
  __includes = { ELEMENT }
}

local next_id = 1

function Actor:init(body, behavior)

  ELEMENT.init(self)

  self.body = body
  self.behavior = behavior
  self.cooldown = 10
  self:setId(("actor#%d"):format(1000+next_id))
  next_id = next_id + 1

end

function Actor:tick()
  self.cooldown = math.max(0, self.cooldown - 1)
end

function Actor:ready()
  return self.cooldown <= 0
end

function Actor:makeAction(map)
  return self:behavior(map) ()
end

function Actor:spendTime(n)
  self.cooldown = self.cooldown + n
end

return Actor
