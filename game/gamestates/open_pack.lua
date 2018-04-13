
local INPUT = require 'input'
local DIRECTIONALS = require 'infra.dir'
local DEFS = require 'domain.definitions'
local PACK = require 'domain.pack'
local PLAYSFX = require 'helpers.playsfx'
local PackView = require 'view.packlist'
local CardView = require 'view.cardlist'

local state = {}

local _card_list_view
local _pack_list_view
local _leave
local _status
local _pack_index

function state:init()
end

local function _prev()
  _card_list_view:selectPrev()
end

local function _next()
  _card_list_view:selectNext()
end

local function _confirm()
  if _status == "choosing_pack" then
    _status = "choosing_card"
    _pack_list_view = PACK.generatePackFrom(_card_list_view:getChosenPack())
    _pack_index = _card_list_view:getSelection()
    _card_list_view:close()
    _card_list_view = CardView({"UP"})
    _card_list_view:open(_pack_list_view)
    _card_list_view:addElement("HUD")
  elseif not _card_list_view:isLocked() then
    _card_list_view:collectCards(function() _leave = true end)
  end
end

local function _cancel()
  if _status == "choosing_pack" then
    _leave = true
  end
end

function state:enter(from, packlist)
  _status = "choosing_pack"
  _pack_list_view = nil
  _card_list_view = PackView({"UP", "CONFIRM"}, packlist)
  if #packlist > 0 then
    _card_list_view:addElement("HUD")
  else
    _leave = true
  end
end

function state:leave()
  _leave = false
  _card_list_view:close()
  _card_list_view = nil
end

function state:update(dt)
  if DEBUG then return end

  MAIN_TIMER:update(dt)

  if _status == "choosing_pack" and
     (_leave or _card_list_view:isPackListEmpty()) then
    PLAYSFX 'back-menu'
    SWITCHER.pop({
      consumed = {},
      pack = nil,
      pack_index = nil,
    })
  elseif _status == "choosing_card" and
         (_leave or _card_list_view:isCardListEmpty()) then
    PLAYSFX 'back-menu'
    SWITCHER.pop({
      consumed = _card_list_view:getConsumeLog(),
      pack = _pack_list_view,
      pack_index = _pack_index
    })
  else
    if _status == "choosing_pack" and _card_list_view:usedHoldbar() then
      _confirm()
    elseif DIRECTIONALS.wasDirectionTriggered('LEFT') then
      _prev()
    elseif DIRECTIONALS.wasDirectionTriggered('RIGHT') then
      _next()
    elseif _status == "choosing_card" and INPUT.wasActionPressed('CONFIRM') then
      _confirm()
    elseif INPUT.wasActionPressed('CANCEL') then
      _cancel()
    end

  end
end

function state:draw()
  Draw.allTables()
end

return state
