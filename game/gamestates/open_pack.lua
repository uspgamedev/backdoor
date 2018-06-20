
local INPUT = require 'input'
local DIRECTIONALS = require 'infra.dir'
local DEFS = require 'domain.definitions'
local PLAYSFX = require 'helpers.playsfx'
local PackView = require 'view.packlist'
local CardView = require 'view.consumelist'

local state = {}

local _route
local _card_list_view
local _pack
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

local function _toggle()
  _card_list_view:toggleSelected()
end

local function _confirm()
  if _status == "choosing_pack" then
    _status = "choosing_card"
    local collection = _card_list_view:getChosenPack()
    _pack = _route.makePack(collection)
    _pack_index = _card_list_view:getSelection()
    _card_list_view:close()
    _card_list_view = CardView({"CONFIRM"})
    _card_list_view:open(_pack)
    _card_list_view:addElement("HUD")
  end
end

local function _cancel()
  if _status == "choosing_pack" then
    _leave = true
  end
end

local function _consumeCards(consumed)
  local count = 0
  for _,i in ipairs(consumed) do
    table.remove(_pack, i-count)
    count = count + 1
  end
end

function state:enter(from, route, packlist)
  _status = "choosing_pack"
  _route = route
  _pack = nil
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
         (_leave or _card_list_view:isReadyToLeave()) then
    PLAYSFX 'back-menu'
    local consume_log = _card_list_view:getConsumeLog()
    _consumeCards(consume_log)
    SWITCHER.pop({
      consumed = consume_log,
      pack = _pack,
      pack_index = _pack_index
    })
  else
    if _status == "choosing_pack" and _card_list_view:usedHoldbar() then
      _confirm()
    elseif DIRECTIONALS.wasDirectionTriggered('LEFT') then
      _prev()
    elseif DIRECTIONALS.wasDirectionTriggered('RIGHT') then
      _next()
    elseif _status == "choosing_card" and
           (DIRECTIONALS.wasDirectionTriggered('UP') or
            DIRECTIONALS.wasDirectionTriggered('DOWN')) then
      _toggle()
    elseif INPUT.wasActionPressed('CANCEL') then
      _cancel()
    end

  end
end

function state:draw()
  Draw.allTables()
end

return state
