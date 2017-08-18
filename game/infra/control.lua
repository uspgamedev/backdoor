-- FIXME: this file needs to follow the code style conventions!

-- MODULE
local controls = {}

-- DEPENDENCIES
local Queue = require 'lux.common.Queue'

-- PRIVATE INFO
local redirect = {
  __index = function (self, k)
    if k == "RELEASE_QUIT" then love.event.quit() end
    return function () end
  end
}
local mapped_controls = {}
local input_queue = Queue(64)

-- PUBLIC METHODS
function controls.enqueue (control)
  input_queue.push(control)
end

function controls.flush ()
  input_queue.popAll()
end

function controls.set_map (m)
  setmetatable(m, redirect)
  mapped_controls = m
end

function controls.getMap()
  return mapped_controls
end

function controls.update ()
  local act
  while not input_queue.isEmpty() do
    act = input_queue.pop()
    mapped_controls[act]()
  end
  input_queue.popAll()
end

controls.set_map(mapped_controls)
return controls
