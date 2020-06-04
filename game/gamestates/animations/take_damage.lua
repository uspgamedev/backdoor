
-- luacheck: globals love MAIN_TIMER

local RisingText  = require 'view.sector.risingtext'
local BodyView    = require 'view.sector.bodyview'
local COLORS      = require 'domain.definitions.colors'
local PLAYSFX     = require 'helpers.playsfx'

local ANIM = require 'common.activity' ()

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
    self.wait(bodyview:hit(push_dir))
  end
end

return ANIM

