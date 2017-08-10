
local Activity  = require 'ufo.Activity'
local Debug     = require 'activities.DebugActivity'

local BootstrapActivity = class:new{}

local print = print

BootstrapActivity:inherit(Activity)

function BootstrapActivity:instance (obj)

  self:super(obj)

  setfenv(1, obj)

  function __accept:Load()
    switch(Debug())
  end

end

return BootstrapActivity

