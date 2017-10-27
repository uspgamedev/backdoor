
local DEFS = require 'domain.definitions'
local CONTROLS = require 'infra.control'
local ManageBufferView = require 'view.managebuffer'

local state = {}

local _view
local _mapping
local _actor
local _consumed
local _leave

function state:init()
  _mapping = {
    PRESS_LEFT = function()
      _view:selectPrev()
    end,
    PRESS_RIGHT = function()
      _view:selectNext()
    end,
    PRESS_UP = function()
      local idx, card = _view:popSelectedCard()
      table.insert(_consumed, idx)
      _view:updateSelection()
      if _view:isBufferEmpty() then _leave = true end
    end,
    PRESS_CONFIRM = function()
      _leave = true
    end,
    PRESS_CANCEL = function()
      _leave = true
    end,
  }
  _view = ManageBufferView(actor)
  _view:addElement("HUD")
end

function state:enter(from, actor)
  _actor = actor
  _consumed = {}

  if _actor:getBackBufferSize() > 0 then
    _leave = false
    _view:open(_actor:copyBackBuffer())
    CONTROLS.setMap(_mapping)
  else
    _leave = true
  end
end

function state:leave()
  _view:close()
end

function state:update(dt)
  if not DEBUG then
    if _leave then SWITCHER.pop(_consumed) end
    MAIN_TIMER:update(dt)
  end
end

function state:draw()
  Draw.allTables()
end

return state



