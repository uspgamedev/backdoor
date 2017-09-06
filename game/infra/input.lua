
-- MODULE
local input = {}

-- DEPENDENCIES
local controls = require 'infra.control'

-- Translate keyboard keys to in-game controls
local key_mapping = {
  f = "CONFIRM",
  d = "CANCEL",
  s = "SPECIAL",
  a = "EXTRA",
  r = "ACTION_1",
  e = "ACTION_2",
  w = "ACTION_3",
  q = "ACTION_4",
  up = "UP",
  right = "RIGHT",
  down = "DOWN",
  left = "LEFT",
  f8 = "QUIT",
  escape = "PAUSE",
}

-- List what action controls the game should check for
local enabled_actions = {
  ACTION_1 = true,
  ACTION_2 = true,
  ACTION_3 = true,
  ACTION_4 = true,
  CONFIRM = true,
  CANCEL = true,
  SPECIAL = true,
  MENU = true,
  UP = true,
  RIGHT = true,
  DOWN = true,
  LEFT = true,
  QUIT = true,
  PAUSE = true,
}

-- Send actions to the control manager
local function send_action (atype, aname)
  if not enabled_actions[aname] then return end
  local full_name = atype .. "_" .. aname
  controls.enqueue(full_name)
end

local function handle_press (key)
  local action_found = key_mapping[key]
  if not action_found then return end
  send_action("PRESS", action_found)
end

local function handle_release (key)
  local action_found = key_mapping[key]
  if not action_found then return end
  send_action("RELEASE", action_found)
end

local function handle_hold (key)
  local action_found = key_mapping[key]
  if not action_found then return end
  send_action("HOLD", action_found)
end

local function check_held_keyboard_keys ()
  for key in pairs(key_mapping) do
    if love.keyboard.isDown(key) then
      handle_hold(key)
    end
  end
end

-- Public methods
function input.key_pressed (key)
  handle_press(key)
end

function input.key_released (key)
  handle_release(key)
end

function input.load ()
  -- check saved input mapping
  -- load default values from a file here
end

function input.update ()
  -- check held controls
  check_held_keyboard_keys()
  controls.update()
end

return input
