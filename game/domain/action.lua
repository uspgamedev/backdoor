
local DIR = require 'domain.definitions.dir'
local FX = require "domain.effects"

local GameElement = require 'domain.gameelement'

----------

local action = {}

function action.IDLE(actor)
  return function()
    FX.spend_time{target = actor, amount = 1}
  end
end

function action.MOVE(map, actor, dir_name)
  local dir = DIR[dir_name]
  assert(dir, ("Invalid direction '%s'"):format(dir_name))
  local i, j = unpack(map.bodies[actor:getBody()])
  local di, dj = unpack(dir)
  i, j = i+di, j+dj
  if map:isValid(i, j) then
    return function()
      map:putBody(actor:getBody(), i, j)
      FX.spend_time{target = actor, amount = 3}
    end
  else
    return action.IDLE(actor)
  end
end

function action.PRIMARY(map, actor)
    return function()
        local _,target = coroutine.yield(
          actor,
          "pick_target",
          {
            pos = {actor:getPos()},
            valid_position_func = function(i, j)
              return map:isInside(i,j) and map.bodies[i][j]
            end
          }
        )
        if target then
            local i,j = unpack(target)
            target = map.bodies[i][j]
            FX.damage{target = target, amount = 2}
            FX.spend_time{target = actor, amount = 3}
        else
            return select(2,coroutine.yield(actor)) ()
        end
    end

end

local actions = {}

actions.IDLE = {
  cost = 1,
  params = {},
  effects = {}
}

actions.MOVE = {
  cost = 3,
  params = {
    { "pos" }
  },
  effects = {
    { "move_to", 1 }
  }
}

actions.SHOOT = {
  cost = 6,
  params = {
    { "body_target" },
  },
  effects = {
    { "damage", 1 },
  }
}


local Action = Class {
  __includes = { ELEMENT }
}

function Action:init(specname, actor, map, params)
  self.spec = actions[specname]
  self.actor = actor
  self.map = map
  self.params = params
end

function Action:run(map)
  local spec = self.spec
  local actor = self.actor
  local map = self.map
  local params = self.params
  actor:spendTime(self.spec.cost)
  for i,effect_spec in ipairs(spec.effects) do
    local args = {}
    local fx_name
    for j,k in ipairs(effect_spec) do
      if j == 1 then
        fx_name = k
      else
        table.insert(args, params[k])
      end
    end
    FX[fx_name](actor, map, unpack(args))
  end
end

return Action

