
local DB           = require 'database'
local DIR          = require 'domain.definitions.dir'
local DIRECTIONALS = require 'infra.dir'
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

  MAIN_TIMER:update(dt)

  if not _alert then
    for _,dir in ipairs(DIR) do
      if DIRECTIONALS.wasDirectionTriggered(dir) then
        _alert = true
      end
    end
    for input in pairs(DB.loadSetting('controls').digital) do
      if INPUT.wasActionPressed(input) then
        _alert = true
      end
    end
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

