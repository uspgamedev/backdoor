
local Route = require 'lux.class' :new{}
local IDGenerator = require 'common.idgenerator'

function Route:instance(obj)

  local _id_generator = IDGenerator()

  Util.destroyAll 'true_force'

  function obj.loadState(state)
    _id_generator = IDGenerator(state.next_id)
  end

  function obj.saveState()
    local state = {}
    state.next_id = _id_generator.getNextID()
    return state
  end

  function obj.register(element)
    local id = _id_generator.newID()
    element:setId(id)
    element:setSubtype(element.spectype)
    return id, element
  end

end

return Route

