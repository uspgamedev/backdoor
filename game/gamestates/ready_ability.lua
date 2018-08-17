
local INPUT          = require 'input'
local DIRECTIONALS   = require 'infra.dir'
local DEFS           = require 'domain.definitions'
local PLAYSFX        = require 'helpers.playsfx'
local ReadyAbilityView = require 'view.readyability'

local max = math.max
local min = math.min

local _HOLDTIME = 0.25


local _view
local _abilities
local _quick_toggle


local function _prev()
  _view:selectPrev()
  PLAYSFX 'select-menu'
end

local function _next()
  _view:selectNext()
  PLAYSFX 'select-menu'
end

local function _confirm()
  PLAYSFX 'ok-menu'
  _view:exitList()
  _abilities.ready = _abilities.list[_view:getSelection()]:getId()
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
  _quick_toggle = 0
  _view = view
  _view:enterList()
end

function state:update(dt)
  if DEBUG then return end
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
end

function state:draw()
  Draw.allTables()
end

return state

