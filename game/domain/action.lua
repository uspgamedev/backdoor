
local ABILITY = require 'domain.ability'
local DB      = require 'database'

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

local ACTION = {}

function ACTION.paramsOf(action_name)
  return ABILITY.paramsOf(DB.loadSpec('action', action_name).ability)
end

function ACTION.run(action_name, actor, sector, params)
  local spec = DB.loadSpec("action", action_name)
  if not ABILITY.checkParams(spec.ability, actor, sector, params) then
    return false
  end
  actor:spendTime(spec.cost)
  actor:rewardPP(spec.playpoints or 0)
  ABILITY.execute(spec.ability, actor, sector, params)
  return true
end

return ACTION

