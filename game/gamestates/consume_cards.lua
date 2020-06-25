
-- luacheck: no self

local INPUT        = require 'input'
local DIRECTIONALS = require 'infra.dir'
local PROFILE      = require 'infra.profile'
local SWITCHER     = require 'infra.switcher'
local PLAYSFX      = require 'helpers.playsfx'
local CardView     = require 'view.consumelist'
local Draw         = require "draw"

local state = {}

local _actor
local _card_list_view
local _leave
local _view

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

local function _cancel()
  _leave = true
end

function state:enter(_, view, actor, maxconsume)
  _view = view
  _view.actor:show()
  _card_list_view = CardView({"CONFIRM"})
  local buffer = actor:copyBuffer()
  _actor = actor
  _card_list_view:open(buffer, maxconsume)
  _card_list_view:register("HUD")
  if #buffer == 0 then
    _leave = true
  end
end

function state:resume()
  _card_list_view:unlockHoldbar()
end

function state:leave()
  _leave = false
  if _card_list_view:getExpGained() > 0 then
    _view.actor:timedHide(1)
  else
    _view.actor:hide()
  end
  _card_list_view:close()
  _card_list_view = nil
end

function state:update(_)
  if not PROFILE.getTutorial("consume") then
    local GS = require 'gamestates'
    _card_list_view:lockHoldbar()
    SWITCHER.push(GS.TUTORIAL_HINT, "consume")
    return
  end
  if _leave then
    PLAYSFX('back-menu', .05)
    SWITCHER.pop({})
  elseif _card_list_view:isReadyToLeave() then
    local consume_log = _card_list_view:getConsumeLog()
    local bufsize = _actor:getBufferSize()
    for i,v in ipairs(consume_log) do
      if v > bufsize then
        consume_log[i] = v + 1
      end
    end
    SWITCHER.pop({
      consumed = consume_log,
    })
  else
    if DIRECTIONALS.wasDirectionTriggered('LEFT') then
      PLAYSFX('select-card', .05)
      _prev()
    elseif DIRECTIONALS.wasDirectionTriggered('RIGHT') then
      PLAYSFX('select-card', .05)
      _next()
    elseif (DIRECTIONALS.wasDirectionTriggered('UP') or
            DIRECTIONALS.wasDirectionTriggered('DOWN')) then
      PLAYSFX('toggle-card', .05)
      _toggle()
    elseif INPUT.wasActionPressed('CANCEL') then
      PLAYSFX('back-menu', .05)
      _cancel()
    end
  end
end

function state:draw()
  Draw.allTables()
end

return state
