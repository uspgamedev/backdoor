
local INPUT = require 'input'
local DIRECTIONALS = require 'infra.dir'
local DEFS = require 'domain.definitions'
local PLAYSFX = require 'helpers.playsfx'
local CardView = require 'view.consumelist'

local state = {}

local _actor
local _card_list_view
local _leave
local _status

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

function state:enter(from, actor, maxconsume)
  _card_list_view = CardView({"CONFIRM"})
  local buffer = actor:copyBuffer()
  _actor = actor
  _card_list_view:open(buffer, maxconsume)
  _card_list_view:addElement("HUD")
  if #buffer == 0 then
    _leave = true
  end
end

function state:leave()
  _leave = false
  _card_list_view:close()
  _card_list_view:destroy()
  _card_list_view = nil
end

function state:update(dt)
  if DEBUG then return end

  MAIN_TIMER:update(dt)

  if _leave then
    PLAYSFX 'back-menu'
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
      _prev()
    elseif DIRECTIONALS.wasDirectionTriggered('RIGHT') then
      _next()
    elseif (DIRECTIONALS.wasDirectionTriggered('UP') or
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
