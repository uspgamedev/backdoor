
local IDGenerator = require 'lux.class' :new{}

local ID_BASE = 0
local ID_FORMAT = "#%04d"

function IDGenerator:instance(obj, first_id) -- luacheck: no self

  local _next_id = first_id or 1

  function obj.getNextID()
    return _next_id
  end

  function obj.newID()
    local id = ID_FORMAT:format(ID_BASE + _next_id)
    _next_id = _next_id + 1
    return id
  end

end

return IDGenerator

