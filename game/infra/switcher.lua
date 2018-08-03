
local Gamestate = require "steaming.extra_libs.hump.gamestate"
local Queue = require 'lux.common.Queue'
local INPUT = require 'input'

local SWITCHER = {}

local _stack_size = 0
local _pushed = false
local _popped = false
local _switched = false

function SWITCHER.init()
end

function SWITCHER.start(to, ...)
  -- call right after init, with the initial gamestate
  -- call it only once!
  _stack_size = 1
  Gamestate.switch(to, ...)
end

function SWITCHER.switch(to, ...)
  INPUT.flush()
  _switched = { to, ... }
end

function SWITCHER.push(to, ...)
  _stack_size = _stack_size + 1
  INPUT.flush()
  _pushed = { to, ... }
end

function SWITCHER.pop(...)
  _stack_size = _stack_size - 1
  INPUT.flush()
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
  if _switched then
    Gamestate.switch(unpack(_switched))
    _switched = false
  end
end

setmetatable(SWITCHER, {
  __index = Gamestate
})

return SWITCHER
