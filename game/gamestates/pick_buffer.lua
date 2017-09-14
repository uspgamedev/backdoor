--MODULE FOR THE GAMESTATE: PICKING A BUFFER--

local DIR = require 'domain.definitions.dir'
local CONTROL = require 'infra.control'

local BufferPickerView = require 'domain.view.bufferpickerview'

local state = {}

--LOCAL VARIABLES--

local _controlled_actor
local _buffer_picker_view

local _previous_control_map

--STATE FUNCTIONS--

function state:enter(_, controlled_actor)

  _controlled_actor = controlled_actor

  _buffer_picker_view = BufferPickerView(_controlled_actor)
  _buffer_picker_view:addElement('HUD')

  local move_selection = function (dir)
    _buffer_picker_view:moveSelection(dir)
  end

  local confirm = function ()
    local args = {
      picked_buffer = _buffer_picker_view:getSelection()
    }
    SWITCHER.pop(args)
  end

  local cancel = function ()
    SWITCHER.pop({})
  end

  Signal.register("move_selection", move_selection)
  Signal.register("confirm", confirm)
  Signal.register("cancel", cancel)

  local signals = {
      PRESS_RIGHT = {"move_selection", "right"},
      PRESS_LEFT = {"move_selection", "left"},
      PRESS_CONFIRM = {"confirm"},
      PRESS_CANCEL = {"cancel"},
  }
  for name, signal in pairs(signals) do
      signals[name] = function ()
          Signal.emit(unpack(signal))
      end
  end
  _previous_control_map = CONTROL.getMap()
  CONTROL.setMap(signals)

end

function state:leave()
    Signal.clear("move_selection")
    Signal.clear("confirm")
    Signal.clear("cancel")
    _buffer_picker_view:destroy()

    CONTROL.setMap(_previous_control_map)
end

function state:update(dt)
  if not DEBUG then
    MAIN_TIMER:update(dt)
  end
end

function state:draw()
    Draw.allTables()
end

-- Return state functions
return state

