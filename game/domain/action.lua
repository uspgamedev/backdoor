
local DIR = require 'domain.definitions.dir'
local FX = require "domain.effects"

local GameElement = require 'domain.gameelement'

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

