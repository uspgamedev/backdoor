
local DIR = require 'domain.definitions.dir'
local FX = require "domain.effects"
local OP = require 'lux.pack' 'domain.operators'
local DB = require 'database'

local GameElement = require 'domain.gameelement'

local function unref(params, values, ref)
  if type(ref) == 'string' then
    local t,n = ref:match '(%w+):(%w+)'
    if t and n then
      if t == 'par' then
        return params[n]
      elseif t == 'val' then
        return values[n]
      end
    end
  end
  return ref
end

local ACTION = {}

function ACTION.paramsOf(action_name)
  return ipairs(DB.loadSpec("action",action_name).params)
end

function ACTION.run(action_name, actor, sector, params)
  local spec = DB.loadSpec("action",action_name)
  local values = {}
  actor:spendTime(spec.cost)
  for i,operation in ipairs(spec.values) do
    local argvalues = {}
    local opname, args, valname = unpack(operation)
    for j,arg in ipairs(args) do
      argvalues[j] = unref(params, values, arg)
    end
    values[valname] = OP[opname](actor, sector, unpack(argvalues))
  end
  for i,effect_spec in ipairs(spec.effects) do
    local argvalues = {}
    local fx_name, args = unpack(effect_spec)
    for j,arg in ipairs(args) do
      argvalues[j] = unref(params, values, arg)
    end
    FX[fx_name](actor, sector, unpack(argvalues))
  end
end

return ACTION
