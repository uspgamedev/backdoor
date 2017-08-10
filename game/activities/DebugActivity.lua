
local Activity  = require 'ufo.Activity'

local DebugActivity = class:new{}

local print = print

DebugActivity:inherit(Activity)

function DebugActivity:instance (obj)

  self:super(obj)

  setfenv(1, obj)

  local gfx

  function __accept.Load(engine)
    gfx = engine.server "Graphics"
    gfx.resetSteps(1)
  end

end

return DebugActivity

