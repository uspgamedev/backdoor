--MODULE FOR THE GAMESTATE: SELECTING A CARD IN HAND--
local INPUT = require 'input'
local DIRECTIONALS = require 'infra.dir'
local PLAYSFX        = require 'helpers.playsfx'

local state = {}

local _LAG = 2.0 -- seconds

--LOCAL VARIABLES--

local _route
local _action_hud
local _actor_view

--LOCAL FUNCTIONS--

local function _confirmCard()
  local args = {
    chose_a_card = true,
    card_index = _action_hud:getHandView():getFocus(),
  }
  if args.card_index > _route.getControlledActor():getHandSize() then
    args.card_index = 'draw-hand'
  end
  SWITCHER.pop(args)
end

local function _cancel()
  local args = {
    chose_a_card = false,
  }
  PLAYSFX 'back-menu'
  _action_hud:deactivateHand()
  SWITCHER.pop(args)
end

--STATE FUNCTIONS--

function state:init()
end

function state:enter(_, route, _view)

  _route = route
  _action_hud = _view.action_hud
  if not _action_hud:isHandActive() then
    _action_hud:activateHand()
  end
  _actor_view = _view.actor
  _action_hud:enableCardInfo()

  --Make cool animation for cards showing up

end

function state:leave()


end

function state:update(dt)

  if DEBUG then return end

  if DIRECTIONALS.wasDirectionTriggered('RIGHT') then
    _action_hud:moveHandFocus("RIGHT")
  elseif DIRECTIONALS.wasDirectionTriggered('LEFT') then
    _action_hud:moveHandFocus("LEFT")
  elseif INPUT.wasActionPressed('CONFIRM') then
    _confirmCard()
  elseif INPUT.wasActionPressed('CANCEL') or
    INPUT.wasActionPressed('ACTION_1') or
    INPUT.wasActionPressed('SPECIAL') then
    _cancel()
  end

  Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

--Return state functions
return state
