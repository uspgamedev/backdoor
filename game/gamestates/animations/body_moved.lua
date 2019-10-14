
-- luacheck: globals MAIN_TIMER

local ANIM = require 'common.activity' ()

function ANIM:script(_, view, report)
  local body = report.body
  local i, j = body:getPos()
  local sectorview = view.sector
  if sectorview:isInsideFov(i, j) then
    local bodyview = sectorview:getBodyView(body)
    self.wait(bodyview:moveTo(i, j, 1/20/report.speed_factor, 'in-out-quad'))
  end
end

return ANIM

