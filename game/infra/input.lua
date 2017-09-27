
-- MODULE
local input = {}

-- DEPENDENCIES
local controls = require 'infra.control'

-- Translate keyboard keys to in-game controls
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

-- List what action controls the game should check for
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

-- Send actions to the control manager
local function _sendAction (atype, aname)
  if not _enabled_actions[aname] then return end
  local full_name = atype .. "_" .. aname
  controls.enqueue(full_name)
end

local function _handlePress (key)
  local action_found = _key_mapping[key]
  if not action_found then return end
  _sendAction("PRESS", action_found)
  _down[action_found] = true
end

local function _handleRelease (key)
  local action_found = _key_mapping[key]
  if not action_found then return end
  _sendAction("RELEASE", action_found)
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

-- Public methods
function input.keyPressed (key)
  _handlePress(key)
end

function input.keyReleased (key)
  _handleRelease(key)
end

function input.isDown (action)
  return _down[action]
end

function input.init ()
  local key_released = love.keyreleased
  local key_pressed = love.keypressed
  local update = love.update
  love.keyreleased = function(key)
    if not DEBUG then input.keyReleased(key) end
    key_released(key)
  end
  love.keypressed = function(key)
    if not DEBUG then input.keyPressed(key) end
    key_pressed(key)
  end
  love.update = function(dt)
    if not DEBUG then input.update() end
    update(dt)
  end
end

function input.loadMapping(key_mapping)
  _key_mapping = key_mapping or _key_mapping
end

function input.getMapping()
  return _key_mapping
end

function input.update ()
  -- check held controls
  _checkHeldKeyboardKeys()
  controls.update()
end

return input
