
local Activity = require 'ufo.Activity'

local BootstrapActivity = class:new{}

local print = print

BootstrapActivity:inherit(Activity)

function BootstrapActivity:instance (obj)

  setfenv(1, obj)

  self:super(obj)

  function __accept:Load()
    print("HUZZAH")
  end

end

return BootstrapActivity

