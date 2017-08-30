
local Gamestate = require "steaming.extra_libs.hump.gamestate"
local Queue = require 'lux.common.Queue'
local Controls = require 'infra.control'

local SWITCHER = {}

local _stack_size = 0
local _pushed = Queue(16)
local _popped = Queue(16)

function SWITCHER.init()
  Gamestate.registerEvents()
end

function SWITCHER.switch(to, ...)
  if _stack_size == 0 then _stack_size = 1 end
  print("SWITCH", _stack_size)
  Controls.flush()
  Gamestate.switch(to, ...)
end

function SWITCHER.push(to, ...)
  _stack_size = _stack_size + 1
  print("PUSH", _stack_size)
  Controls.flush()
  _pushed.push { to, ... }
end

function SWITCHER.pop(...)
  _stack_size = _stack_size - 1
  print("POP", _stack_size)
  Controls.flush()
  _popped.push { ... }
end

function SWITCHER.handleChangedState()
  while not _popped.isEmpty() do
    Gamestate.pop(unpack(_popped.pop()))
  end
  while not _pushed.isEmpty() do
    Gamestate.push(unpack(_pushed.pop()))
  end
end

setmetatable(SWITCHER, {
  __index = Gamestate
})

return SWITCHER
