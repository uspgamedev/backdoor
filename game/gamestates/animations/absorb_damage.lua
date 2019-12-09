
local TweenValue    = require 'view.helpers.tweenvalue'
local CardView      = require 'view.card'
local Util          = require "steaming.util"
local vec2          = require 'cpml' .vec2

local ANIM = require 'common.activity' ()

local _OFFSET = 20
local _DURATION = .4

local _waitAndAnnounce
local _slideUp
local _slideDown

function ANIM:script(route, view, report)
  local delay = TweenValue(0)
  local action_hud = view.action_hud
  if report.actor == route:getControlledActor() then
    local widgetview = action_hud:getWidgetCard(report.widget)
    _waitAndAnnounce(report.widget, self.wait)
    _slideUp(widgetview, self)
    self.wait(delay:set(0.2))
    _slideDown(widgetview, self)
    self.wait(delay:set(_DURATION))
  end
  delay:kill()
end

function _waitAndAnnounce(widget, wait)
  local ann = Util.findId('announcement')
  ann:lock()
  local deferred = ann:interrupt()
  if deferred then wait(deferred) end
  ann:announce(widget:getName())
  ann:unlock()
end

function _slideUp(cardview, task)
  local delay = TweenValue(0)
  local target_pos = vec2(cardview.position.x, cardview.position.y - _OFFSET)
  cardview:flashFor(_DURATION)
  cardview:addTimer("slide_up", MAIN_TIMER, "tween", _DURATION, cardview,
                    { position = target_pos }, 'out-cubic',
                    function () task.resume() end)
  task.wait()
  delay:kill()
end

function _slideDown(cardview, task)
  local delay = TweenValue(0)
  local target_pos = vec2(cardview.position.x, cardview.position.y + _OFFSET)
  cardview:addTimer("slide_down", MAIN_TIMER, "tween", _DURATION, cardview,
                    { position = target_pos }, 'out-cubic',
                    function () task.resume() end)
  task.wait()
  delay:kill()
end

return ANIM
