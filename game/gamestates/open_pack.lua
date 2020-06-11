
-- luacheck: no self

local INPUT        = require 'input'
local DIRECTIONALS = require 'infra.dir'
local PROFILE      = require 'infra.profile'
local SWITCHER     = require 'infra.switcher'
local PLAYSFX      = require 'helpers.playsfx'
local PackView     = require 'view.packlist'
local CardView     = require 'view.consumelist'
local Draw         = require "draw"

local state = {}

local _route
local _card_list_view
local _pack
local _leave
local _view
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
    _pack = _route.makePack(collection, _route.getControlledActor())
    _pack_index = _card_list_view:getSelection()
    _card_list_view:close()
    _card_list_view = CardView({"CONFIRM"})
    _card_list_view:open(_pack)
    _card_list_view:register("HUD")
    _card_list_view:sendToBackbuffer(_view.backbuffer)
    _view.actor:show()
    if not PROFILE.getTutorial("consume") then
      local GS = require 'gamestates'
      _card_list_view:lockHoldbar()
      SWITCHER.push(GS.TUTORIAL_HINT, "consume")
      return
    end
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

function state:enter(_, view, route, packlist)
  _view = view
  _view.action_hud.minimap:hide()
  _status = "choosing_pack"
  _route = route
  _pack = nil
  _card_list_view = PackView({"UP", "CONFIRM"}, packlist)
  if #packlist > 0 then
    _card_list_view:register("HUD")
  else
    _leave = true
  end
end

function state:resume()
  _card_list_view:unlockHoldbar()
end

function state:leave()
  if _card_list_view.getExpGained and _card_list_view:getExpGained() > 0 then
    _view.actor:timedHide(1)
  else
    _view.actor:hide()
  end
  _view.action_hud.minimap:show()
  _leave = false
  _card_list_view:close()
  _card_list_view = nil
end

function state:update(_)
  if not PROFILE.getTutorial("open_pack") then
    local GS = require 'gamestates'
    _card_list_view:lockHoldbar()
    SWITCHER.push(GS.TUTORIAL_HINT, "open_pack")
    return
  end
  if _status == "choosing_pack" and
     (_leave or _card_list_view:isPackListEmpty()) then
    PLAYSFX('back-menu', .05)
    SWITCHER.pop({
      consumed = {},
      pack = nil,
      pack_index = nil,
    })
  elseif _status == "choosing_card" and
         (_leave or _card_list_view:isReadyToLeave()) then
    PLAYSFX('back-menu', .05)
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
