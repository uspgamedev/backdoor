-- luacheck: globals MAIN_TIMER

local TweenValue    = require 'view.helpers.tweenvalue'

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  local delay = TweenValue(0)
  local action_hud = view.action_hud
  if report.actor == route:getControlledActor() then
    local frontbuffer = view.frontbuffer
    local backbuffer = view.backbuffer
    local d = .7
    backbuffer:changeSide(d, frontbuffer)
    self.wait(delay:set(d))
  end
  delay:kill()
end

return ANIM
