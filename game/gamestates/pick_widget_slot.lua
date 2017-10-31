
local DEFS = require 'domain.definitions'
local PickWidgetView = require 'view.pickwidget'
local CONTROLS = require 'infra.control'

local state = {}

local _view
local _selection
local _validate
local _target
local _mapping
local _leave

function state:init()
  _mapping = {
    PRESS_UP = function()
      _selection = (_selection - 2) % _target:getBody():getWidgetCount() + 1
    end,
    PRESS_DOWN = function()
      _selection = _selection % _target:getBody():getWidgetCount() + 1
    end,
    PRESS_CONFIRM = function()
      if _validate(_selection) then
        _view:fadeOut()
        SWITCHER.pop({ picked_slot = _selection })
      end
    end,
    PRESS_CANCEL = function()
      _view:fadeOut()
      SWITCHER.pop({})
    end,
  }
end

function state:enter(from, actor, validator)
  _target = actor
  _validate = validator
  _selection = 1
  _leave = actor:getBody():getWidgetCount() <= 0

  if not _leave then
    CONTROLS.setMap(_mapping)

    _view = PickWidgetView(actor)
    _view:addElement("HUD")
    _view:fadeIn()
  end
end

function state:update(dt)
  if not DEBUG then
    MAIN_TIMER:update(dt)
    if _leave then
      (_view and _view.fadeOut or DEFS.NULL_METHOD)(_view)
      SWITCHER.pop({})
    else
      _view:setSelection(_selection)
    end
  end
end

function state:draw()
  Draw.allTables()
end

return state

