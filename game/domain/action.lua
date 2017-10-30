
local MANEUVERS = require 'lux.pack' 'domain.maneuver'
local ABILITY = require 'domain.ability'
local DB      = require 'database'

local ACTION = {}

function ACTION.exists(action_name)
  return not not MANEUVERS[action_name]
end

function ACTION.pendingParam(action_name, actor, sector, params)
  local maneuver = MANEUVERS[action_name]
  for _,param_spec in ipairs(maneuver.param_specs) do
    if not params[param_spec.output] then
      return param_spec
    end
  end
  local activated_ability = maneuver.activatedAbility(actor, sector, params)
  if activated_ability then
    for _,param_spec in ABILITY.paramsOf(activated_ability) do
      if not params[param_spec.output] then
        return param_spec
      end
    end
  end
end

function ACTION.ability(action_name)
  return (DB.loadSpec('action', action_name) or {}).ability
end

function ACTION.execute(action_slot, actor, sector, params)
  local maneuver = MANEUVERS[action_slot]
  if not maneuver or not maneuver.validate(actor, sector, params) then
    return false
  end
  maneuver.perform(actor, sector, params)
  return true
end

return ACTION

