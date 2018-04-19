
local VIEWDEFS  = require 'view.definitions'
local RNG       = require 'common.random'
local SPRITEFX  = {}

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H

local _DELAY = 0.05
local _DURATION = 0.2

function SPRITEFX.apply(sectorview, args)
  local i, j = unpack(args.origin)
  local drops = args.drops
  local finished = 0
  local total = #drops
  local count = 1

  local offsets = {}
  for t,drop in ipairs(drops) do
    local ti, tj, k = unpack(drop)
    local offset = {t=0, i=i, j=j}
    sectorview:setDropOffset(ti, tj, k, offset)
    offsets[t] = offset
  end

  local function launch()
    local drop = drops[count]
    local offset = offsets[count]
    count = count + 1
    local ti, tj, k = unpack(drop)
    sectorview:addTimer(
      nil, MAIN_TIMER, "tween", _DURATION, offset, {t=1}, 'in-out-linear',
      function()
        finished = finished + 1
        if finished >= total then
          sectorview:finishVFX()
        end
      end
    )
  end

  launch()
  sectorview:addTimer(nil, MAIN_TIMER, "every", _DELAY, launch, #drops-1)
end

return SPRITEFX

