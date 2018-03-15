
local MANEUVERS = require 'lux.pack' 'domain.maneuver'
local ABILITY = require 'domain.ability'
local DB      = require 'database'

local ACTION = {}

function ACTION.exists(action_name)
  return not not MANEUVERS[action_name]
end

function ACTION.pendingInput(action_name, actor, inputvalues)
  local maneuver = MANEUVERS[action_name]
  for _,input_spec in ipairs(maneuver.input_specs) do
    if not inputvalues[input_spec.output] then
      return input_spec
    end
  end
  local activated_ability = maneuver.activatedAbility(actor, inputvalues)
  if activated_ability then
    for _,input_spec in ABILITY.inputsOf(activated_ability) do
      if not inputvalues[input_spec.output] then
        return input_spec
      end
    end
  end
end

function ACTION.ability(action_name)
  return (DB.loadSpec('action', action_name) or {}).ability
end

function ACTION.execute(action_slot, actor, inputvalues)
  local maneuver = MANEUVERS[action_slot]
  if not maneuver or not maneuver.validate(actor, inputvalues) then
    return false
  end
  maneuver.perform(actor, inputvalues)
  return true
end

return ACTION

