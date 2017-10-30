
local DEFS = require 'domain.definitions'
local CONTROLS = require 'infra.control'
local ManageBufferView = require 'view.cardlist'

local state = {}

local _view
local _mapping
local _leave

function state:init()
  _mapping = {
    PRESS_LEFT = function()
      _view:selectPrev()
    end,
    PRESS_RIGHT = function()
      _view:selectNext()
    end,
    PRESS_CONFIRM = function()
      if not _view:isLocked() then _leave = true end
    end,
    PRESS_CANCEL = function()
      if not _view:isLocked() then _leave = true end
    end,
  }
  _view = ManageBufferView("UP")
  _view:addElement("HUD")
end

function state:enter(from, actor)
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
    if _leave or _view:isCardListEmpty() then
      SWITCHER.pop({consumed = _view:getConsumeLog()})
    end
    MAIN_TIMER:update(dt)
  end
end

function state:draw()
  Draw.allTables()
end

return state



