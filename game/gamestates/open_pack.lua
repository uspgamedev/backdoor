
local CONTROLS = require 'infra.control'
local DEFS = require 'domain.definitions'
local PACK = require 'domain.pack'
local PackView = require 'view.cardlist'

local state = {}

local _view
local _mapping
local _pack
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
      if not _view:isLocked() then
        CONTROLS.setMap()
        _view:collectCards(function() _leave = true end)
      end
    end,
  }
end

function state:enter(from, actor)
  _pack = PACK.generatePackFrom(actor:getSpec('collection'))
  _view = PackView("UP")
  if #_pack > 0 then
    CONTROLS.setMap(_mapping)
    _view:addElement("HUD")
  else
    _leave = true
  end
  _view:open(_pack)
end

function state:leave()
  _leave = false
  _view:close()
  _view = nil
end

function state:update(dt)
  if not DEBUG then
    if _leave or _view:isCardListEmpty() then
      SWITCHER.pop({
        consumed = _view:getConsumeLog(),
        pack = _pack
      })
    end
    MAIN_TIMER:update(dt)
  end
end

function state:draw()
  Draw.allTables()
end

return state



