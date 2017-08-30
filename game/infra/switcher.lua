
local Gamestate = require "steaming.extra_libs.hump.gamestate"
local Queue = require 'lux.common.Queue'
local Controls = require 'infra.control'

local SWITCHER = {}

local _stack_size = 0
local _pushed = false
local _popped = false

function SWITCHER.init()
  Gamestate.registerEvents()
end

function SWITCHER.switch(to, ...)
  if _stack_size == 0 then _stack_size = 1 end
  Controls.flush()
  Gamestate.switch(to, ...)
end

function SWITCHER.push(to, ...)
  _stack_size = _stack_size + 1
  Controls.flush()
  _pushed = { to, ... }
end

function SWITCHER.pop(...)
  _stack_size = _stack_size - 1
  Controls.flush()
  _popped = { ... }
end

function SWITCHER.handleChangedState()
  if _popped then
    Gamestate.pop(unpack(_popped))
    _popped = false
  end
  if _pushed then
    Gamestate.push(unpack(_pushed))
    _pushed = false
  end
end

setmetatable(SWITCHER, {
  __index = Gamestate
})

return SWITCHER
