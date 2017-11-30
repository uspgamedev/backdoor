
local DIR   = require 'domain.definitions.dir'
local INPUT = require 'infra.input'
local state = {}

local _sector_view
local _current_dir

local function _updateDir(dir)
  _current_dir = DIR[dir]
  _sector_view:setRayDir(_current_dir)
end

function state:enter(prev, sector_view)
  _sector_view = sector_view
  _updateDir(DIR[1])
end

function state:update(dt)
  MAIN_TIMER:update(dt)

  for _,dir in ipairs(DIR) do
    if INPUT.actionPressed(dir:upper()) then
      _updateDir(dir)
    end
  end

  if INPUT.actionPressed('CONFIRM') then
    _sector_view:setRayDir()
    SWITCHER.pop(_current_dir)
  elseif INPUT.actionPressed('CANCEL') then
    _sector_view:setRayDir()
    SWITCHER.pop()
  end
end

function state:draw()
  Draw.allTables()
end

return state

