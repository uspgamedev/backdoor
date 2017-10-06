
local DB = require 'database'
local DEFS = require 'domain.definitions'
local PickWidgetView = require 'view.pickwidget'
local CONTROLS = require 'infra.control'

local state = {}

local _view
local _selection
local _validate
local _target
local _mapping

function state:init()
  _mapping = {
    PRESS_UP = function()
      _selection = (_selection - 2) % DEFS.WIDGET_LIMIT + 1
    end,
    PRESS_DOWN = function()
      _selection = _selection % DEFS.WIDGET_LIMIT + 1
    end,
    PRESS_CONFIRM = function()
      if _validate(_selection) then
        _view:fadeOut()
        SWITCHER.pop({ picked_slot = DEFS.WIDGETS[_selection] })
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

  CONTROLS.setMap(_mapping)

  _view = PickWidgetView(actor)
  _view:addElement("HUD")
  _view:fadeIn()
end

function state:update(dt)
  if not DEBUG then
    MAIN_TIMER:update(dt)
  end
  _view:setSelection(_selection)
end

function state:draw()
  Draw.allTables()
end

return state

