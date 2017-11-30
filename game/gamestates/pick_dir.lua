
local DIR   = require 'domain.definitions.dir'
local INPUT = require 'infra.input'
local state = {}

local _sector_view
local _current_dir

function state:enter(prev, sector_view)
  _sector_view = sector_view
  _current_dir = DIR[1]
end

function state:update(dt)
  MAIN_TIMER:update(dt)

  for _,dir in ipairs(DIR) do
    if INPUT.actionPressed(dir:upper()) then
      -- nope
    end
  end

  if INPUT.actionPressed('CONFIRM') then
    SWITCHER.pop(_current_dir)
  elseif INPUT.actionPressed('CANCEL') then
    SWITCHER.pop(_current_dir)
  end
end

return state

