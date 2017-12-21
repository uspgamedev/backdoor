

local state = {}

--[[ LOCAL VARIABLES ]]--

local _sector_view

--[[ LOCAL FUNCTIONS ]]--

--[[ STATE FUNCTIONS ]]--

function state:init()
  -- dunno
end

function state:enter(_, sector_view, animation)

  _sector_view = sector_view

end

function state:leave()

  Util.destroyAll()

end

function state:update(dt)

  MAIN_TIMER:update(dt)

  if not _sector_view:hasPendingVFX() then
    SWITCHER.pop()
  else
    _sector_view:updateVFX(dt)
  end

  Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

return state

