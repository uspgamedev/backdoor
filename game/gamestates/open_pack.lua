
local CONTROLS = require 'infra.control'
local DEFS = require 'domain.definitions'
local Card = require 'domain.card'
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
      CONTROLS.setMap()
      _view:collectCards(function() _leave = true end)
    end,
  }
  _view = PackView("UP")
  _view:addElement("HUD")
end

function state:enter(from, actor)
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



