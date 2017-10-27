
local FX = require 'lux.pack' 'domain.effects'
local OP = require 'lux.pack' 'domain.operators'
local PAR = require 'lux.pack' 'domain.params'
local DB = require 'database'

local function unref(params, values, ref)
  if type(ref) == 'string' then
    local t,n = ref:match '(%w+):(.+)'
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

local ABILITY = {}

function ABILITY.paramsOf(ability)
  return ipairs(ability.params)
end

function ABILITY.param(param_name)
  return PAR[param_name]
end

function ABILITY.validate(param_name, sector, actor, param, value)
  return PAR[param_name].isValid(sector, actor, param, value)
end

function ABILITY.checkParams(ability, actor, sector, params)
  for i,parameter in ipairs(ability.params) do
    local paramspec = PAR[parameter.typename]
    if not paramspec.isValid(sector, actor, parameter,
                             params[parameter.output]) then
      return false
    end
  end
  return true
end

function ABILITY.execute(ability, actor, sector, params)
  local values = {}
  for i,operation in ipairs(ability.operators) do
    local argvalues = {}
    local opname, valname = operation.typename, operation.output
    for _,arg in DB.schemaFor('operators/'..opname) do
      argvalues[arg.id] = unref(params, values, operation[arg.id])
    end
    values[valname] = OP[opname].process(actor, sector, argvalues)
  end
  for i,effect_spec in ipairs(ability.effects) do
    local argvalues = {}
    local fx_name = effect_spec.typename
    for _,arg in DB.schemaFor('effects/'..fx_name) do
      argvalues[arg.id] = unref(params, values, effect_spec[arg.id])
    end
    FX[fx_name].process(actor, sector, argvalues)
  end
end

return ABILITY

