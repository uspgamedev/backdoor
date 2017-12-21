--MODULE FOR THE GAMESTATE: SELECTING A CARD IN HAND--
local INPUT = require 'input'
local DIRECTIONALS = require 'infra.dir'


local state = {}


--LOCAL VARIABLES--

local _route
local _hand_view

--LOCAL FUNCTIONS--

local function _moveFocus(dir)
  _hand_view:moveFocus(dir)
end

local function _changeActionType(dir)
  _hand_view:changeActionType(dir)
end

local function _confirmCard()
  local args = {
    chose_a_card = true,
    action_type = _hand_view:getActionType(),
    card_index = _hand_view:getFocus(),
  }
  SWITCHER.pop(args)
end

local function _cancel()
  local args = {
    chose_a_card = false,
  }
  SWITCHER.pop(args)
end

--STATE FUNCTIONS--

function state:init()
end

function state:enter(_, route, hand_view)

  _route = route
  _hand_view = hand_view
  _hand_view:activate()

  --Make cool animation for cards showing up

end

function state:leave()

  _hand_view:deactivate()

end

function state:update(dt)

  if DEBUG then return end
  MAIN_TIMER:update(dt)

  if DIRECTIONALS.wasDirectionTriggered('RIGHT') then
    _moveFocus("RIGHT")
  elseif DIRECTIONALS.wasDirectionTriggered('LEFT') then
    _moveFocus("LEFT")
  elseif DIRECTIONALS.wasDirectionTriggered('UP') then
    _changeActionType("UP")
  elseif DIRECTIONALS.wasDirectionTriggered('DOWN') then
    _changeActionType("DOWN")
  elseif INPUT.wasActionPressed('CONFIRM') then
    _confirmCard()
  elseif INPUT.wasActionPressed('CANCEL') or
    INPUT.wasActionPressed('ACTION_1') or
    INPUT.wasActionPressed('SPECIAL') then
    _cancel()
  end

end

function state:draw()

    Draw.allTables()

end

--Return state functions
return state
