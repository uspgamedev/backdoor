
local Actor = Class{
  __includes = { ELEMENT }
}

function Actor:init(body)

  ELEMENT.init(self)

  self.body = body
  self.cooldown = 10
  self.next_action = nil

end

function Actor:tick()
  self.cooldown = math.max(0, self.cooldown - 1)
end

function Actor:ready()
  return self.cooldown <= 0
end

function Actor:hasAction()
  return self.next_action
end

function Actor:getAction()
  local action = self.next_action
  self.next_action = nil
  return action
end

function Actor:setAction(action)
  self.next_action = action
end

function Actor:spendTime(n)
  self.cooldown = self.cooldown + n
end

return Actor
