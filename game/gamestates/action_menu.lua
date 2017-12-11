
--- GAMESTATE: Choosing an action

local INPUT          = require 'input'
local DIRECTIONALS   = require 'infra.dir'
local ActionMenuView = require 'view.actionmenu'

local state = {}

--[[ LOCAL VARIABLES ]]--

local _menu_view
local _last_focus

--[[ LOCAL FUNCTIONS ]]--

local function _moveFocus(dir)
  _menu_view:moveFocus(dir)
end

local function _confirm()
  _last_focus = _menu_view:getCurrentFocus()
  _menu_view:close()
  SWITCHER.pop({ action = _menu_view:getSelected() })
end

local function _cancel()
  _last_focus = _menu_view:getCurrentFocus()
  _menu_view:close()
  SWITCHER.pop({})
end

--[[ STATE FUNCTIONS ]]--

function state:init()
  _menu_view = ActionMenuView()
  _menu_view:addElement('HUD')
end

function state:enter(_, route)

  local player = route.getControlledActor()
  local action = 'draw_new_hand'
  if player:getHandSize() > 0 then action = 'play_card' end
  _menu_view:setCardAction(action)
  _menu_view:open(_last_focus, player)

end

function state:leave()
end

function state:update(dt)
  if DEBUG then return end

  MAIN_TIMER:update(dt)

  local axis = DIRECTIONALS.getFromAxes()
  local hat = DIRECTIONALS.getFromHat()
  local input_dir = axis or hat
  if INPUT.wasActionPressed('UP') or input_dir == 'up' then
    _moveFocus('up')
  elseif INPUT.wasActionPressed('DOWN') or input_dir == 'down' then
    _moveFocus('down')
  elseif INPUT.wasActionPressed('CONFIRM') then
    _confirm()
  elseif INPUT.wasActionPressed('CANCEL') or
    INPUT.wasActionPressed('EXTRA') then
    _cancel()
  end

end

function state:draw()

  Draw.allTables()

end

return state

