
-- luacheck: globals MAIN_TIMER

local SPRITEFX  = {}

local _DELAY = 0.05
local _DURATION = 0.2

function SPRITEFX.apply(sectorview, args)
  local i, j = unpack(args.pos)
  local drops = args.drops
  local finished = 0
  local total = #drops
  local count = 1

  if total <= 0 then
    return sectorview:finishVFX()
  end

  local offsets = {}
  for t,drop in ipairs(drops) do
    local ti, tj, k = unpack(drop)
    local offset = {t=0, i=i, j=j}
    sectorview:setDropOffset(ti, tj, k, offset)
    offsets[t] = offset
  end

  local function launch()
    local offset = offsets[count]
    count = count + 1
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

