
-- luacheck: globals SWITCHER, no self

local INPUT        = require 'input'
local DIRECTIONALS = require 'infra.dir'
local DIR          = require 'domain.definitions.dir'
local PLAYSFX      = require 'helpers.playsfx'
local Draw         = require "draw"

local state = {}

local _sector_view
local _current_dir
local _body_block
local _reach

local function _updateDir(dir)
  _current_dir = DIR[dir]
  _sector_view:setRayDir(_current_dir, _body_block, _reach)
end

function state:enter(_, sector_view, param)
  _sector_view = sector_view
  _body_block = param['body-block']
  _reach = param['reach']
  _updateDir(DIR[1])
end

function state:leave()
end

function state:update(_)
  if INPUT.wasActionPressed('CONFIRM') then
    _sector_view:setRayDir()
    SWITCHER.pop(_current_dir)
  elseif INPUT.wasActionPressed('CANCEL') then
    _sector_view:setRayDir()
    PLAYSFX('back-menu')
    SWITCHER.pop()
  else
    for _,dir in ipairs(DIR) do
      if DIRECTIONALS.wasDirectionTriggered(dir) then
        _updateDir(dir)
      end
    end
  end
end

function state:draw()
  Draw.allTables()
end

return state
