
-- MODULE
local INPUT = {}

-- DEPENDENCIES
local CONTROL = require 'infra.control'

-- Translate keyboard keys to in-game CONTROL
local _key_mapping = {
  f       = "CONFIRM",
  d       = "CANCEL",
  s       = "SPECIAL",
  a       = "EXTRA",
  r       = "ACTION_1",
  e       = "ACTION_2",
  w       = "ACTION_3",
  q       = "ACTION_4",
  up      = "UP",
  right   = "RIGHT",
  down    = "DOWN",
  left    = "LEFT",
  [7]     = "UPLEFT",
  [9]     = "UPRIGHT",
  [3]     = "DOWNRIGHT",
  [1]     = "DOWNLEFT",
  home    = "UPLEFT",
  pageup  = "UPRIGHT",
  pagedown= "DOWNRIGHT",
  ["end"] = "DOWNLEFT",
  y       = "UPLEFT",
  u       = "UPRIGHT",
  n       = "DOWNRIGHT",
  b       = "DOWNLEFT",
  k       = "UP",
  l       = "RIGHT",
  j       = "DOWN",
  h       = "LEFT",
  f8      = "QUIT",
  escape  = "PAUSE",
}

-- List what action CONTROL the game should check for
local _enabled_actions = {
  ACTION_1 = true,
  ACTION_2 = true,
  ACTION_3 = true,
  ACTION_4 = true,
  CONFIRM = true,
  CANCEL = true,
  SPECIAL = true,
  EXTRA = true,
  MENU = true,
  UP = true,
  RIGHT = true,
  DOWN = true,
  LEFT = true,
  UPLEFT = true,
  UPRIGHT = true,
  DOWNLEFT = true,
  DOWNRIGHT = true,
  QUIT = true,
  PAUSE = true,
}

local _down = {}
local _pressed = {}

-- Send actions to the control manager
local function _sendAction (atype, aname)
  if not _enabled_actions[aname] then return end
  local full_name = atype .. "_" .. aname
  CONTROL.enqueue(full_name)
end

local function _handlePress (key)
  local action_found = _key_mapping[key]
  if not action_found then return end
  _sendAction("PRESS", action_found)
  _pressed[action_found] = not _down[action_found]
  _down[action_found] = true
end

local function _handleRelease (key)
  local action_found = _key_mapping[key]
  if not action_found then return end
  _sendAction("RELEASE", action_found)
  _pressed[action_found] = false
  _down[action_found] = false
end

local function _handleHold (key)
  local action_found = _key_mapping[key]
  if not action_found then return end
  _sendAction("HOLD", action_found)
  _down[action_found] = true
end

local function _checkHeldKeyboardKeys ()
  for key in pairs(_key_mapping) do
    if love.keyboard.isDown(key) then
      _handleHold(key)
    end
  end
end

--[[ Public methods ]]--

function INPUT.actionPressed(action)
  return _pressed[action]
end

function INPUT.keyPressed (key)
  _handlePress(key)
end

function INPUT.keyReleased (key)
  _handleRelease(key)
end

function INPUT.isDown (action)
  return _down[action]
end

function INPUT.init ()
  local key_released = love.keyreleased
  local key_pressed = love.keypressed
  local update = love.update
  love.keyreleased = function(key)
    if not DEBUG then INPUT.keyReleased(key) end
    key_released(key)
  end
  love.keypressed = function(key)
    if not DEBUG then INPUT.keyPressed(key) end
    key_pressed(key)
  end
  love.update = function(dt)
    if not DEBUG then INPUT.update() end
    update(dt)
    for k,v in pairs(_pressed) do
      _pressed[k] = false
    end
  end
end

function INPUT.loadMapping(key_mapping)
  _key_mapping = key_mapping or _key_mapping
end

function INPUT.getMapping()
  return _key_mapping
end

function INPUT.update ()
  -- check held CONTROL
  _checkHeldKeyboardKeys()
  CONTROL.update()
end

return INPUT

