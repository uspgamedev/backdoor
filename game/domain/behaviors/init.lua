
local Behaviors = require 'lux.class' :new{}

function Behaviors:instance(obj)

  local _ai = {}

  function obj.load(state)
    local actor_ai_state = state.ai
    local ai = {}
    for actor_id, actor_ai_state in pairs(_ai) do
      local actor_ai = {}
      local target_id = actor_ai_state.target
      actor_ai.target = target_id and Util.findId(target_id)
      actor_ai.target_pos = actor_ai_state.target_pos
      ai[actor_id] = actor_ai
    end
    _ai = ai
  end

  function obj.save()
    local state = {}
    local ai_states = {}
    for actor_id, actor_ai in pairs(_ai) do
      local actor_ai_state = {}
      local target = actor_ai.target
      actor_ai_state.target = target and target:getId()
      actor_ai_state.target_pos = actor_ai.target_pos
      ai_states[actor_id] = actor_ai_state
    end
    state.ai = ai_states
    return state
  end

  function obj.newAI(actor)
    local actor_ai = {
      target = false,
      target_pos = false,
    }
    _ai[actor:getId()] = actor_ai
    return actor_ai
  end

  function obj.getAI(actor)
    return _ai[actor:getId()]
  end

  function obj.removeAI(actor)
    _ai[actor:getId()] = nil
  end

end

return Behaviors

