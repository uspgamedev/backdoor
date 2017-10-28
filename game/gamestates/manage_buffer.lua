
local DEFS = require 'domain.definitions'
local CONTROLS = require 'infra.control'
local ManageBufferView = require 'view.cardlist'

local state = {}

local _view
local _mapping
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
      CONTROLS.setMap()
      table.insert(_consumed, idx)
      _view:updateSelection()
      if _view:isCardListEmpty() then
        _leave = true
      else
        _view:addTimer("consuming_lock", MAIN_TIMER, "after", .2,
                       function() CONTROLS.setMap(_mapping) end)
      end
    end,
    PRESS_CONFIRM = function()
      _leave = true
    end,
    PRESS_CANCEL = function()
      _leave = true
    end,
  }
  _view = ManageBufferView()
  _view:addElement("HUD")
end

function state:enter(from, actor)
  _consumed = {}

  if actor:getBackBufferSize() > 0 then
    _leave = false
    _view:open(actor:copyBackBuffer())
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
    if _leave then SWITCHER.pop({consumed = _consumed}) end
    MAIN_TIMER:update(dt)
  end
end

function state:draw()
  Draw.allTables()
end

return state



