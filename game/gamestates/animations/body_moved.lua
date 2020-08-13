
-- luacheck: globals MAIN_TIMER

local PLAYSFX = require 'helpers.playsfx'

local ANIM = require 'common.activity' ()

function ANIM:script(_, view, report)
  local body = report.body
  local i, j = body:getPos()
  local sectorview = view.sector
  local bodyview = sectorview:getBodyView(body)
  if sectorview:isInsideFov(i, j) then
    PLAYSFX('footstep')
    self.wait(bodyview:moveTo(i, j, 1/20/report.speed_factor, 'in-out-quad'))
  else
    bodyview:setPosition(i, j)
  end
end

return ANIM
