
--- GAMESTATE: Opening a card pack

local CONTROL   = require 'infra.control'
local PackView  = require 'view.pack'

local state = {}

--[[ LOCAL VARIABLES ]]--

local _pack_view
local _picks

local _mapped_signals
local _previous_control_map

local SIGNALS = {
  PRESS_RIGHT = {"move_focus", "right"},
  PRESS_LEFT = {"move_focus", "left"},
  PRESS_UP = {"consume_card"},
  PRESS_CONFIRM = {"confirm"},
}

--[[ LOCAL FUNCTIONS DECLARATIONS ]]--

local _unregisterSignals
local _registerSignals

--[[ LOCAL FUNCTIONS ]]--

local function _moveFocus(dir)
  _pack_view:moveFocus(dir)
end

local function _consumeCard()
  table.insert(_picks, {
    action_type = "consume",
    buffer_index = 0,
    card_index = _pack_view:getFocusedCardIndex(),
  })
  _pack_view:consumeCard()
  if _pack_view:isEmpty() then
    SWITCHER.pop(_picks)
    _picks = nil
  end
end

local function _confirm()
  while not _pack_view:isEmpty() do
    table.insert(_picks, {
      action_type = "get",
      buffer_index = 1,
      card_index = _pack_view:getFocusedCardIndex(),
    })
    _pack_view:removeCurrent()
  end
  SWITCHER.pop(_picks)
  _picks = nil
end

function _registerSignals()
  Signal.register("move_focus", _moveFocus)
  Signal.register("consume_card", _consumeCard)
  Signal.register("confirm", _confirm)
  CONTROL.setMap(_mapped_signals)
end

function _unregisterSignals()
  for _,signal_pack in pairs(SIGNALS) do
    Signal.clear(signal_pack[1])
  end
  CONTROL.setMap(_previous_control_map)
end

--[[ STATE FUNCTIONS ]]--

function state:init()
  _mapped_signals = {}
  for input_name, signal_pack in pairs(SIGNALS) do
    _mapped_signals[input_name] = function ()
      Signal.emit(unpack(signal_pack))
    end
  end
end

function state:enter(_, route)

  local controlled_actor = route:getControlledActor()

  controlled_actor:openPack()

  _pack_view = PackView(controlled_actor)
  _pack_view:addElement('HUD')
  _picks = {}

  _registerSignals()

  _previous_control_map = CONTROL.getMap()
  CONTROL.setMap(_mapped_signals)

end

function state:leave()

  _pack_view:kill()
  _pack_view = nil

  Util.destroyAll()

  _unregisterSignals()

end

function state:update(dt)

  if not DEBUG then
    MAIN_TIMER:update(dt)
  end

  Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

return state
