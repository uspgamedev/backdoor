
--MODULE FOR THE GAMESTATE: GAME--

local ACTION = require 'domain.action'
local DB = require 'database'
local DIR = require 'domain.definitions.dir'
local INPUT = require 'infra.input'
local CONTROL = require 'infra.control'
local GUI = require 'debug.gui'

local Route = require 'domain.route'
local SectorView = require 'domain.view.sectorview'

local state = {}

--LOCAL VARIABLES--

local _route
local _player
local _next_action

local _task

local _sector_view
local _gui

local SIGNALS = {
  PRESS_UP = {"move", "up"},
  PRESS_DOWN = {"move", "down"},
  PRESS_RIGHT = {"move", "right"},
  PRESS_LEFT = {"move", "left"},
  PRESS_ACTION_1 = {"widget_1"},
  PRESS_ACTION_2 = {"widget_2"},
  PRESS_ACTION_3 = {"widget_3"},
  PRESS_ACTION_4 = {"widget_4"},
  PRESS_SPECIAL = {"start_card_turn"},
  PRESS_CANCEL = {"wait"},
  PRESS_PAUSE = {"pause"},
  PRESS_QUIT = {"quit"}
}

--LOCAL FUNCTIONS--

local function _moveActor(dir)
  local current_sector = _route.getCurrentSector()
  local controlled_actor = _route.getControlledActor()
  local i, j = controlled_actor:getPos()
  dir = DIR[dir]
  i, j = i+dir[1], j+dir[2]
  if current_sector:isValid(i,j) then
    _next_action = {'MOVE', { pos = {i,j} }}
  end
end

local function _usePrimaryAction()
  local current_sector = _route.getCurrentSector()
  local controlled_actor = _route.getControlledActor()
  local action_name = controlled_actor:getAction('PRIMARY')
  local params = {}
  for _,param in ACTION.paramsOf(action_name) do
    if param[1] == 'choose_target' then
      SWITCHER.push(
        GS.PICK_TARGET, _sector_view,
        {
          pos = { controlled_actor:getPos() },
          valid_position_func = function(i, j)
            return current_sector:isInside(i,j) and
                   current_sector:getBodyAt(i,j)
          end
        }
      )
      local args = coroutine.yield(_task)
      if args.target_is_valid then
        params[param[3]] = current_sector:getBodyAt(unpack(args.pos))
      else
        return
      end
    end
  end
  _next_action = {'PRIMARY', params}
end

local function _resumeTask(...)
  if _task then
    local _
    _, _task = assert(coroutine.resume(_task, ...))
  end
end

local function _makeSignalHandler(callback)
  return function (...)
    local controlled_actor = _route.getControlledActor()
    if controlled_actor then
      _task = coroutine.create(callback)
      return _resumeTask(...)
    end
  end
end

local function _playTurns(...)
  _route.playTurns(...)
  _next_action = nil
end

--STATE FUNCTIONS--

function state:init()
  for name, signal in pairs(SIGNALS) do
    SIGNALS[name] = function ()
      Signal.emit(unpack(signal))
    end
  end
end

function state:enter()

  _route = Route()

  local sector = _route.makeSector('sector01')

  _sector_view = SectorView(sector)
  _sector_view:addElement("L1", nil, "sector_view")

  for _=1,5 do
    _route.makeActor('slime', 'dumb', sector:randomValidTile())
  end

  _player = _route.makeActor('hearthborn', 'player', sector:randomValidTile())
  _sector_view:lookAt(_player)

  _playTurns()

  Signal.register("move", _makeSignalHandler(_moveActor))
  Signal.register("widget_1", _makeSignalHandler(_usePrimaryAction))
  CONTROL.setMap(SIGNALS)

  _gui = GUI(_sector_view)
  _gui:addElement("GUI")

end

function state:leave()

  Util.destroyAll("force")

end

function state:update(dt)

  if not DEBUG then
    INPUT.update()
    if _next_action then
      _playTurns(unpack(_next_action))
    end
    _sector_view:lookAt(_route.getControlledActor() or _player)
  end

  Util.destroyAll()

end

function state:resume(state, args)
  if state == GS.PICK_TARGET then

    _resumeTask(args)

  end
end

function state:draw()

  Draw.allTables()

end

function state:keypressed(key)

  imgui.KeyPressed(key)
  if imgui.GetWantCaptureKeyboard() then
    return
  end

  if not DEBUG then
    INPUT.key_pressed(key)
  end

  if key ~= "escape" then
    Util.defaultKeyPressed(key)
  end

end

function state:textinput(t)
  imgui.TextInput(t)
end

function state:keyreleased(key)

  imgui.KeyReleased(key)
  if imgui.GetWantCaptureKeyboard() then
    return
  end

  if not DEBUG then
    INPUT.key_released(key)
  end

end

function state:mousemoved(x, y)
  imgui.MouseMoved(x, y)
end

function state:mousepressed(x, y, button)
  imgui.MousePressed(button)
end

function state:mousereleased(x, y, button)
  imgui.MouseReleased(button)
end

function state:wheelmoved(x, y)
  imgui.WheelMoved(y)
end

--Return state functions
return state
