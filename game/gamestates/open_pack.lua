
local INPUT = require 'input'
local DIRECTIONALS = require 'infra.dir'
local DEFS = require 'domain.definitions'
local PACK = require 'domain.pack'
local PackView = require 'view.packlist'
local CardView = require 'view.cardlist'

local state = {}

local _view
local _pack
local _leave
local _status

function state:init()
end

local function _prev()
  _view:selectPrev()
end

local function _next()
  _view:selectNext()
end

local function _confirm()
  if _status == "choosing_pack" then
    _pack = PACK.generatePackFrom(_view:getChosenPack())
    _view:close()
    _status = "choosing_card"
    _view = CardView("UP")
    _view:open(_pack)
  elseif not _view:isLocked() then
    _view:collectCards(function() _leave = true end)
  end
end

function state:enter(from, packlist)
  _pack = nil
  _status = "choosing_pack"
  _view = PackView("UP", packlist)
  if #packlist > 0 then
    _view:addElement("HUD")
  else
    _leave = true
  end
end

function state:leave()
  _leave = false
  _view:close()
  _view = nil
end

function state:update(dt)
  if DEBUG then return end

  MAIN_TIMER:update(dt)

  if _status == "choosing_pack" and (_leave or _view:isPackListEmpty()) then
    print("okay")
    SWITCHER.pop({
      consumed = {},
      pack = nil
    })
  elseif _status == "choosing_card" and (_leave or _view:isCardListEmpty()) then
    SWITCHER.pop({
      consumed = _view:getConsumeLog(),
      pack = _pack
    })
  else

    if DIRECTIONALS.wasDirectionTriggered('LEFT') then
      _prev()
    elseif DIRECTIONALS.wasDirectionTriggered('RIGHT') then
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
