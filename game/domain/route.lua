
local Route = require 'lux.class' :new{}

local ID_BASE = 1000
local ID_FORMAT = "#%d"

function Route:instance(obj)

  local _next_id = 1

  Util.destroyAll 'true_force'

  function obj.loadState(state)

  end

  function obj.saveState()
    local state = {}
    return state
  end

  function obj.register(element)
    local id = ID_FORMAT:format(ID_BASE + _next_id)
    element:setId(id)
    _next_id = _next_id + 1
    return id, element
  end

end

return Route

