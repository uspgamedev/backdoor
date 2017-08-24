
local GameElement = require 'domain.gameelement'
local ACTION      = require 'domain.action'

local Actor = Class{
  __includes = { GameElement }
}

function Actor:init(spec_name)

  GameElement.init(self, 'actor', spec_name)

  self.behavior = require('domain.behaviors.' .. self:getSpec 'behavior')

  self.body_id = nil
  self.cooldown = 10
  self.actions = {
    IDLE = true,
    MOVE = true,
    PRIMARY = "SHOOT"
  }

end

function Actor:loadState(state)

end

function Actor:saveState(state)

end

function Actor:setBody(body_id)
  self.body_id = body_id
end

function Actor:getBody()
  return Util.findId(self.body_id)
end

function Actor:getPos()
  return self:getBody():getPos()
end

function Actor:getAction(name)
  return self.actions[name]
end

function Actor:tick()
  self.cooldown = math.max(0, self.cooldown - 1)
end

function Actor:ready()
  return self.cooldown <= 0
end

function Actor:makeAction(sector)
  local action_name, params = self:behavior(sector)
  local check = self.actions[action_name]
  if check then
    local action
    if check == true then
      action = action_name
    else
      action = check
    end
    return ACTION.run(action, self, sector, params)
  end
end

function Actor:spendTime(n)
  self.cooldown = self.cooldown + n
end

return Actor
