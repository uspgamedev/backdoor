--MODULE FOR THE GAMESTATE: PICKING A BUFFER--

local DIR = require 'domain.definitions.dir'
local CONTROL = require 'infra.control'

local BufferPickerView = require 'domain.view.bufferpickerview'

local state = {}

--LOCAL VARIABLES--

local _controlled_actor
local _buffer_picker_view

local _previous_control_map
local _filter

--FILTER CLASS--

local Filter = Class{
  __includes = {ELEMENT}
}

function Filter:init(_r, _g, _b, _a, _target_a)
  ELEMENT.init(self)

  self.r = _r
  self.g = _g
  self.b = _b
  self.a = _a

  --Fade-in effect
  ELEMENT.addTimer(self,"start", MAIN_TIMER, "tween",.2, self, {a = _target_a}, 'out-quad')

end

function Filter:draw()
  local f = self
  local g = love.graphics
  g.setColor(f.r,f.g,f.b,f.a)
  g.rectangle("fill", 0, 0, O_WIN_W, O_WIN_H)
end

--STATE FUNCTIONS--

function state:enter(_, controlled_actor, is_valid_buffer)

  _controlled_actor = controlled_actor

  --Create filter effect
  local initial_a = 0
  if _filter then
    _filter:removeTimer("end", MAIN_TIMER)
    initial_a = _filter.a
    _filter:destroy()
  end

  _filter = Filter(0,0,0, initial_a, 180)
  _filter:addElement('HUD_BG')


  --Create buffer view
  _buffer_picker_view = BufferPickerView(_controlled_actor)
  _buffer_picker_view:addElement('HUD')

  local move_selection = function (dir)
    _buffer_picker_view:moveSelection(dir)
  end

  local confirm = function ()
    local selection = _buffer_picker_view:getSelection()
    if not is_valid_buffer(selection) then return end
    local args = {
      picked_buffer = selection
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
    _filter:addTimer("end", MAIN_TIMER, "tween", .2, _filter, {a = 0}, 'in-linear', function() _filter:destroy() end)

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
