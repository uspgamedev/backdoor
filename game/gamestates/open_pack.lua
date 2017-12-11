
local INPUT = require 'input'
local DEFS = require 'domain.definitions'
local PACK = require 'domain.pack'
local PackView = require 'view.cardlist'

local state = {}

local _view
local _pack
local _leave

function state:init()
end

local function _prev()
  _view:selectPrev()
end

local function _next()
  _view:selectNext()
end

local function _confirm()
  if not _view:isLocked() then
    _view:collectCards(function() _leave = true end)
  end
end

function state:enter(from, collection)
  _pack = PACK.generatePackFrom(collection)
  _view = PackView("UP")
  if #_pack > 0 then
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
  if DEBUG then return end

  MAIN_TIMER:update(dt)

  if _leave or _view:isCardListEmpty() then
    SWITCHER.pop({
      consumed = _view:getConsumeLog(),
      pack = _pack
    })
  else

    if INPUT.wasActionPressed('LEFT') then
      _prev()
    elseif INPUT.wasActionPressed('RIGHT') then
      _next()
    elseif INPUT.wasActionPressed('CONFIRM') then
      _confirm()
    end

  end
end

function state:draw()
  Draw.allTables()
end

return state



