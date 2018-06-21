
local INPUT          = require 'input'
local DIRECTIONALS   = require 'infra.dir'
local DEFS           = require 'domain.definitions'
local PLAYSFX        = require 'helpers.playsfx'
local ReadyAbilityView = require 'view.readyability'

local max = math.max
local min = math.min

local _HOLDTIME = 0.25


local _view
local _selection
local _abilities
local _ability_count
local _quick_toggle


local function _prev()
  _selection = (_selection - 2) % _ability_count + 1
  PLAYSFX 'select-menu'
end

local function _next()
  _selection = _selection % _ability_count + 1
  PLAYSFX 'select-menu'
end

local function _confirm()
  PLAYSFX 'ok-menu'
  _view:exitList()
  _abilities.ready = _abilities.list[_selection]:getId()
  SWITCHER.pop()
end

local function _cancel()
  _view:exitList()
  PLAYSFX 'back-menu'
  SWITCHER.pop({})
end


local state = {}

function state:enter(from, abilities, view)
  _abilities = abilities
  _selection = 1
  for i,ability in ipairs(abilities.list) do
    if ability:getId() == abilities.ready then
      _selection = i
      break
    end
  end
  _ability_count = #_abilities.list
  _quick_toggle = 0
  _view = view
  _view:enterList()
end

function state:update(dt)
  if DEBUG then return end
  MAIN_TIMER:update(dt)
  _quick_toggle = min(_HOLDTIME, _quick_toggle + dt)
  if INPUT.wasActionReleased('ACTION_2') then
    if _quick_toggle < _HOLDTIME then
      _next()
      _confirm()
    else
      _confirm()
    end
  elseif DIRECTIONALS.wasDirectionTriggered('UP') then
    _quick_toggle = _HOLDTIME
    _next()
  elseif DIRECTIONALS.wasDirectionTriggered('DOWN') then
    _quick_toggle = _HOLDTIME
    _prev()
  elseif INPUT.wasActionPressed('CONFIRM') then
    _confirm()
  end
  _view:setSelection(_selection)
end

function state:draw()
  Draw.allTables()
end

return state

