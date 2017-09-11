
local DIR = require 'domain.definitions.dir'
local FX = require 'lux.pack' 'domain.effects'
local OP = require 'lux.pack' 'domain.operators'
local PAR = require 'lux.pack' 'domain.params'
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
  return ipairs(DB.loadSpec("action", action_name).params)
end

function ACTION.run(action_name, actor, sector, params)
  local spec = DB.loadSpec("action", action_name)
  local values = {}
  for i,parameter in ipairs(spec.params) do
    local paramspec = PAR[parameter.typename]
    if not paramspec.isValid(sector, actor, params[paramspec.output]) then
      return false
    end
  end
  actor:spendTime(spec.cost)
  for i,operation in ipairs(spec.operators) do
    local argvalues = {}
    local opname, valname = operation.typename, operation.output
    for _,arg in DB.schemaFor('operators/'..opname) do
      argvalues[arg.id] = unref(params, values, operation[arg.id])
    end
    values[valname] = OP[opname].process(actor, sector, argvalues)
  end
  for i,effect_spec in ipairs(spec.effects) do
    local argvalues = {}
    local fx_name = effect_spec.typename
    for _,arg in DB.schemaFor('effects/'..fx_name) do
      argvalues[arg.id] = unref(params, values, effect_spec[arg.id])
    end
    FX[fx_name].process(actor, sector, argvalues)
  end
  return true
end

return ACTION
