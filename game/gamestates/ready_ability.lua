
local INPUT          = require 'input'
local DIRECTIONALS   = require 'infra.dir'
local DEFS           = require 'domain.definitions'
local PLAYSFX        = require 'helpers.playsfx'
local PickWidgetView = require 'view.pickwidget'

local max = math.max
local min = math.min

local _HOLDTIME = 0.25


local _view
local _selection
local _widgets
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
  _view:fadeOut()
  SWITCHER.pop({ picked_slot = _selection })
end

local function _cancel()
  _view:fadeOut()
  PLAYSFX 'back-menu'
  SWITCHER.pop({})
end


local state = {}

function state:enter(from, widgets)
  _widgets = widgets
  _selection = 1
  _ability_count = #_widgets
  _quick_toggle = 0
  _view = PickWidgetView(widgets)
  _view:addElement("HUD")
  _view:fadeIn()
end

function state:update(dt)
  if DEBUG then return end
  MAIN_TIMER:update(dt)
  _quick_toggle = min(_HOLDTIME, _quick_toggle + dt)
  if INPUT.wasActionReleased('ACTION_4') then
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

