
local DEFS = require 'domain.definitions'
local CONTROLS = require 'infra.control'
local ManageBufferView = require 'view.managebuffer'

local state = {}

local _view
local _mapping
local _actor
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
      local cardinfo = _view:popSelectedCard()
      _actor:consumeCard(cardinfo.card)
      _actor:removeBufferCard(cardinfo.idx)
      _view:updateBuffer(_actor:getOrganizedBackBuffer())
      _view:updateSelection()
      if _view:isBufferEmpty() then SWITCHER.pop() end
    end,
    PRESS_CONFIRM = function()
      SWITCHER.pop({})
    end,
    PRESS_CANCEL = function()
      SWITCHER.pop({})
    end,
  }
  _view = ManageBufferView(actor)
end

function state:enter(from, actor)
  _actor = actor

  if _actor:getBackBufferSize() > 0 then
    CONTROLS.setMap(_mapping)
    _view:addElement("HUD")
    _view:open(_actor:getOrganizedBackBuffer())
    _leave = false
  else
    _leave = true
  end
end

function state:leave()
  _view:close()
end

function state:update(dt)
  if not DEBUG then
    if _leave then SWITCHER.pop() end
    MAIN_TIMER:update(dt)
  end
end

function state:draw()
  Draw.allTables()
end

return state



