
-- luacheck: globals MAIN_TIMER

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report) -- luacheck: no self
  if report.actor == route.getControlledActor() then
    view.frontbuffer.ppcounter:setPP(route.getControlledActor():getPP())
  end
end

return ANIM
