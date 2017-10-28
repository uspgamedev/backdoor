
local CONTROLS = require 'infra.control'
local DEFS = require 'domain.definitions'
local Card = require 'domain.card'
local ManageBufferView = require 'view.managebuffer'

local state = {}

local _view
local _mapping
local _consumed
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
    PRESS_UP = function()
      local idx, card = _view:popSelectedCard()
      CONTROLS.setMap()
      table.insert(_consumed, card)
      _view:updateSelection()
      if _view:isCardListEmpty() then
        _leave = true
      else
        _view:addTimer("consuming_lock", MAIN_TIMER, "after", .2,
                       function() CONTROLS.setMap(_mapping) end)
      end
    end,
    PRESS_CONFIRM = function()
      CONTROLS.setMap()
      _view:collectCards(function() _leave = true end)
    end,
  }
  _view = ManageBufferView(actor)
  _view:addElement("HUD")
end

function state:enter(from, actor)
  _consumed = {}
  _pack = {}

  actor:openPack()
  for i,card_specname in actor:iteratePack() do
    local card = Card(card_specname)
    table.insert(_pack, card)
  end
  while actor:hasOpenPack() do actor:removePackCard(1) end

  CONTROLS.setMap(_mapping)
  _view:open(_pack)
end

function state:leave()
  _leave = false
  _view:close()
end

function state:update(dt)
  if not DEBUG then
    if _leave then SWITCHER.pop({
        consumed = _consumed,
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



