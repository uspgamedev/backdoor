
-- luacheck: globals love MAIN_TIMER

local VIEWDEFS    = require 'view.definitions'
local PARTICLES   = require 'view.helpers.particles'
local RisingText  = require 'view.sector.risingtext'
local BodyView    = require 'view.sector.bodyview'
local AnimationFX = require 'view.helpers.animationfx'
local COLORS      = require 'domain.definitions.colors'
local PLAYSFX     = require 'helpers.playsfx'

local vec2        = require 'cpml' .vec2

local ANIM = require 'common.activity' ()

function ANIM:script(_, view, report)
  local body = report.body
  local i, j = body:getPos()
  local sectorview = view.sector
  if sectorview:isInsideFov(i, j) then
    local bodyview = sectorview:getBodyView(body)
    local heal_text = ("+%d"):format(report.amount)
    local x, y = bodyview:getScreenPosition():unpack()
    local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
    PARTICLES({
      position = vec2(x + w/2, y + h/2),
      colors = {COLORS.TRANSP, COLORS.SUCCESS, COLORS.SUCCESS, COLORS.TRANSP},
      emission_area = {"uniform", 20, 2, 0, false},
      emmision_rate = 10,
      number = 15,
      max_number = 30,
      sizes = 3,
      lifetime = .9,
      spread = 0,
      direction = 3*math.pi/2,
      duration = 1
    })
    if report.sfx then PLAYSFX(report.sfx) end
    RisingText(bodyview, heal_text, COLORS.SUCCESS):play()
  end
end

return ANIM
