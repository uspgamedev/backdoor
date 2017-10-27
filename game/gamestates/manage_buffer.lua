
local DEFS = require 'domain.definitions'
local CONTROLS = require 'infra.control'
local ManageBufferView = require 'view.managebuffer'

local state = {}

local _view
local _selection
local _mapping
local _actor

function state:init()
  _mapping = {
    PRESS_LEFT = function()
      _selection = (_selection - 2) % #DEFS.WIDGETS + 1
    end,
    PRESS_RIGHT = function()
      _selection = _selection % #DEFS.WIDGETS + 1
    end,
    PRESS_CONFIRM = function()
    end,
    PRESS_CANCEL = function()
      _view:fadeOut()
      SWITCHER.pop({})
    end,
  }
  _view = ManageBufferView(actor)
end

function state:enter(from, actor)
  _actor = actor
  _selection = 1

  CONTROLS.setMap(_mapping)

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



