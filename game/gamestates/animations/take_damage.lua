
-- luacheck: globals love MAIN_TIMER

local RisingText  = require 'view.sector.risingtext'
local BodyView    = require 'view.sector.bodyview'
local COLORS      = require 'domain.definitions.colors'
local PLAYSFX     = require 'helpers.playsfx'

local Deferred    = require 'common.deferred'

local ANIM = require 'common.activity' ()

local BLINK = { true, false, true, false, true, false }

function ANIM:script(_, view, report)
  local body = report.body
  local i, j = body:getPos()
  local sectorview = view.sector
  if sectorview:isInsideFov(i, j) then
    local bodyview = sectorview:getBodyView(body)
    local damage_text = ("-%d"):format(report.amount)
    if report.sfx then PLAYSFX(report.sfx) end
    RisingText(bodyview, damage_text, COLORS.NOTIFICATION):play()
    local source_pos = BodyView.tileToScreen(report.source:getPos())
    local push_dir = (bodyview:getPosition() - source_pos):normalize()
    local offset = push_dir * 24
    offset = { x = offset.x, y = offset.y }
    local deferred = Deferred:new{}
    bodyview:addTimer(nil, MAIN_TIMER, 'tween', 0.1, bodyview.offset, offset,
                      'in-cubic', function() deferred:trigger() end)
    self.wait(deferred)
    local count = 1
    bodyview:addTimer(
      nil, MAIN_TIMER, 'every', 0.075,
      function()
        bodyview.invisible = BLINK[count]
        count = count + 1
      end,
      #BLINK
    )
    deferred = Deferred:new{}
    bodyview:addTimer(nil, MAIN_TIMER, 'tween', 0.4, bodyview.offset,
                      { x = 0, y = 0}, 'out-cubic',
                      function() deferred:trigger() end)
    self.wait(deferred)
  end
end

return ANIM

