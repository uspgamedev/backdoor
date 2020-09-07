
-- luacheck: globals MAIN_TIMER

local COLORS        = require 'domain.definitions.colors'
local CardView      = require 'view.card'
local VIEWDEFS      = require 'view.definitions'
local RisingText    = require 'view.sector.risingtext'
local vec2          = require 'cpml' .vec2

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  local action_hud = view.action_hud
  if report.body == route.getPlayerActor():getBody() then
    local cardview = CardView(report.card)
    local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
    cardview:register("HUD_FX")

    cardview:setPosition(w/2, h/2)
    local dock = action_hud:getDockFor(cardview.card)
    local destination = dock:getAvailableSlotPosition()
    local mode = dock:getCardMode()

    local offset = vec2(0, -2*VIEWDEFS.CARD_H)

    if dock:getCardMode() == 'cond' then
      dock:updateConditionsPositions(dock:getConditionsCount() + 1)
    elseif dock:getCardMode() == 'equip' then
      dock:updateDockPosition(true)
    end

    cardview:addTimer("slide", MAIN_TIMER, "tween", .6, cardview,
                      {position = destination + offset}, 'out-cubic',
      function()
        cardview:setMode(mode)
        cardview:addTimer("wait", MAIN_TIMER, "after", .1,
              function()
                action_hud.handview.cardinfo:lockCard()
                action_hud:disableCardInfo()
                cardview:addTimer("final_slide", MAIN_TIMER, "tween", .6,
                                  cardview, {position = destination},
                                  'out-cubic',
                  function()
                    dock:addCard(cardview)
                    self.resume()
                  end)
              end)
      end)


    self.wait()
  else
    local bodyview = view.sector:getBodyView(report.body)
    RisingText(bodyview, report.card:getName(), COLORS.WARNING):play()
  end
end

return ANIM
