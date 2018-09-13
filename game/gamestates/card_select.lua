--MODULE FOR THE GAMESTATE: SELECTING A CARD IN HAND--
local INPUT = require 'input'
local DIRECTIONALS = require 'infra.dir'
local PLAYSFX        = require 'helpers.playsfx'

local state = {}

local _LAG = 2.0 -- seconds

--LOCAL VARIABLES--

local _route
local _hud_animator
local _actor_view

--LOCAL FUNCTIONS--

local function _confirmCard()
  local args = {
    chose_a_card = true,
    card_index = _hud_animator:getHandView():getFocus(),
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
  _hud_animator:getHandView():deactivate()
  SWITCHER.pop(args)
end

--STATE FUNCTIONS--

function state:init()
end

function state:enter(_, route, _view)

  _route = route
  _hud_animator = _view.animator
  if not _hud_animator:isHandActive() then
    _hud_animator:activateHand()
  end
  _actor_view = _view.actor
  _hud_animator:enableCardInfo()

  --Make cool animation for cards showing up

end

function state:leave()

  _hud_animator:disableCardInfo()

end

function state:update(dt)

  if DEBUG then return end

  if DIRECTIONALS.wasDirectionTriggered('RIGHT') then
    _hud_animator:moveHandFocus("RIGHT")
  elseif DIRECTIONALS.wasDirectionTriggered('LEFT') then
    _hud_animator:moveHandFocus("LEFT")
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
