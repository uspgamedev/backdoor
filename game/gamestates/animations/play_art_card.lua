
local Util          = require "steaming.util"
local TweenValue    = require 'view.helpers.tweenvalue'
local VIEWDEFS      = require 'view.definitions'
local Dissolve      = require 'view.dissolvecard'
local vec2          = require 'cpml' .vec2

local ANIM = require 'common.activity' ()

-- luacheck: no self, globals MAIN_TIMER

local _waitAndAnnounce
local _slideRight
local _slideDown
local _dissolve

function ANIM:script(route, view, report)
  local action_hud = view.action_hud
  local delay = TweenValue(0)
  local bodyview = view.sector:getBodyView(report.actor:getBody())
  if report.actor == route:getControlledActor() then
    local cardview = action_hud.handview.hand[report.card_index]
    local backbuffer = view.backbuffer
    _waitAndAnnounce(cardview.card:getName(), self.wait)
    self.wait(bodyview:act())
    action_hud.handview:keepFocusedCard(false)
    action_hud.handview:removeCard(report.card_index)
    action_hud.handview.cardinfo:lockCard(cardview.card)
    cardview:setAlpha(1)
    cardview:setFocus(false)
    cardview:register("HUD_FX")
    _slideRight(cardview, backbuffer, self)
    action_hud.handview.cardinfo:lockCard()
    action_hud:disableCardInfo()
    if not cardview.temporary and not cardview.card:isOneTimeOnly() then
      _slideDown(cardview, backbuffer)
    else
      _dissolve(cardview)
    end
  else
    view.sector:setTempTarget(report.actor)
    local card = report.actor:getHandCard(report.card_index)
    _waitAndAnnounce(card:getName(), self.wait)
    self.wait(bodyview:act())
    self.wait(delay:set(1.0))
    view.sector:setTempTarget(nil)
  end
  delay:kill()
  return self
end

function _waitAndAnnounce(text, wait)
  local ann = Util.findId('announcement')
  ann:lock()
  local deferred = ann:interrupt()
  if deferred then wait(deferred) end
  ann:announce(text)
  ann:unlock()
end

function _slideRight(cardview, backbuffer, task)
  local delay = TweenValue(0)
  local target_pos = backbuffer:getTopCardPosition()
                   - vec2(0,VIEWDEFS.CARD_H) * 2
  cardview:addTimer("slide_right", MAIN_TIMER, "tween", .5, cardview,
                    { position = target_pos }, 'out-cubic',
                    function () task.resume() end)
  task.wait()
  task.wait(delay:set(0.2))
  delay:kill()
end

function _slideDown(cardview, backbuffer)
    cardview:addTimer("slide_down", MAIN_TIMER, "tween", .5, cardview,
                      { position = backbuffer:getTopCardPosition() },
                      'out-cubic')
    cardview:addTimer("wait", MAIN_TIMER, "after", .3,
                      function ()
                        cardview:addTimer("fadeout", MAIN_TIMER, "tween", .3,
                                          cardview, {alpha = 0}, 'out-cubic',
                                          function() cardview:kill() end)
                      end)
end

function _dissolve(cardview)
  local delay = TweenValue(0)
  delay:set(1.6):andThen(function () cardview:kill() end)
  Dissolve(cardview, 1.5)
  delay:kill()
end

return ANIM
