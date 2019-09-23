-- luacheck: globals MAIN_TIMER

local TweenValue    = require 'view.helpers.tweenvalue'

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  local delay = TweenValue(0)
  local action_hud = view.action_hud
  if report.actor == route:getControlledActor() then
    local frontbuffer = view.frontbuffer
    local backbuffer = view.backbuffer
    local d = .8
    backbuffer:changeSide(d, frontbuffer, report.actor)
    self.wait(delay:set(d-.1))
  end
  delay:kill()
end

return ANIM
