
-- luacheck: globals love MAIN_TIMER

local RisingText  = require 'view.sector.risingtext'
local COLORS      = require 'domain.definitions.colors'
local Sparkle     = require 'view.gameplay.actionhud.fx.sparkle'
local VIEWDEFS    = require 'view.definitions'

local Util        = require 'steaming.util'
local vec2        = require 'cpml' .vec2

local _NUMBER_COLOR = {
  ['blocked-damage'] = 'LIGHT_GRAY',
  damage = 'NOTIFICATION',
  heal = 'SUCCESS',
  food = 'PP',
  focus = 'FOCUS',
  status = 'WARNING'
}

local _SIGNALS = {
  ['blocked-damage'] = '↓-',
  damage = '-',
  heal = '+',
  focus = '+',
  food = '+',
}

local ANIM = require 'common.activity' ()

function ANIM:script(_, view, report)
  local body = report.body
  local i, j = body:getPos()
  local sectorview = view.sector
  if sectorview:isInsideFov(i, j) then
    local text_type = report.text_type
    local signal = _SIGNALS[text_type]
    local text
    if report.string then
      text = report.string
    else
      text = ("%s%d"):format(signal, report.amount)
    end
    local bodyview = sectorview:getBodyView(body)
    local color = COLORS[_NUMBER_COLOR[text_type]]
    local deferred = RisingText(bodyview, text, color):play()
    if text_type == 'food' then
      local fbuffer = Util.findId('frontbuffer_view')
      local route = body:getSector():getRoute()
      local controlled_actor = route.getControlledActor()
      local controlled_body = controlled_actor:getBody()
      if body == controlled_body then
        local camera_pos = vec2(VIEWDEFS.VIEWPORT_DIMENSIONS()) / 2
        self.wait(Sparkle():go(camera_pos, fbuffer:getCenter()))
        fbuffer.ppcounter:setPP(controlled_actor:getPP())
      end
    else
      self.wait(deferred)
    end
  end
end

return ANIM
