
local INPUT        = require 'input'

local state = {}

--[[ LOCAL VARIABLES ]]--

local _sector_view
local _alert

--[[ LOCAL FUNCTIONS ]]--

--[[ STATE FUNCTIONS ]]--

function state:init()
  -- dunno
end

function state:enter(_, sector_view, animation)

  _sector_view = sector_view
  _alert = false

end

function state:leave()

  Util.destroyAll()

end

function state:update(dt)

  if INPUT.wasAnyPressed(0.5) then
    _alert = true
  end

  if not _sector_view:hasPendingVFX() then
    SWITCHER.pop(_alert)
  else
    _sector_view:updateVFX(dt)
  end

  Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

return state

