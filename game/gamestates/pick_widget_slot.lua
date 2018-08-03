
local INPUT = require 'input'
local DIRECTIONALS = require 'infra.dir'
local DEFS = require 'domain.definitions'
local PLAYSFX = require 'helpers.playsfx'
local PickWidgetView = require 'view.pickwidget'

local state = {}

local _view
local _selection
local _validate
local _target
local _leave


local function _prev()
  _selection = (_selection - 2) % _target:getBody():getWidgetCount() + 1
end

local function _next()
  _selection = _selection % _target:getBody():getWidgetCount() + 1
end

local function _confirm()
  if _validate(_selection) then
    _view:fadeOut()
    SWITCHER.pop({ picked_slot = _selection })
  end
end

local function _cancel()
  _view:fadeOut()
  PLAYSFX 'back-menu'
  SWITCHER.pop({})
end

function state:enter(from, actor, validator)
  _target = actor
  _validate = validator
  _selection = 1
  _leave = actor:getBody():getWidgetCount() <= 0

  if not _leave then
    _view = PickWidgetView(actor)
    _view:addElement("HUD")
    _view:fadeIn()
  end
end

function state:update(dt)
  if not DEBUG then
    if _leave then
      (_view and _view.fadeOut or DEFS.NULL_METHOD)(_view)
      SWITCHER.pop({})
    else
      if DIRECTIONALS.wasDirectionTriggered('UP') then
        _prev()
      elseif DIRECTIONALS.wasDirectionTriggered('DOWN') then
        _next()
      elseif INPUT.wasActionPressed('CONFIRM') then
        _confirm()
      elseif INPUT.wasActionPressed('CANCEL') then
        _cancel()
      end
      _view:setSelection(_selection)
    end
  end
end

function state:draw()
  Draw.allTables()
end

return state

