
local Gamestate = require "steaming.extra_libs.hump.gamestate"

local SWITCHER = {}

local _pushed = false
local _popped = false

function SWITCHER.init()
  Gamestate.registerEvents()
end

function SWITCHER.push(to, ...)
  _pushed = { to, ... }
end

function SWITCHER.pop(...)
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
