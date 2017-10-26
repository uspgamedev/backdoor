
local DEFS = require 'domain.definitions'
local Queue = require 'lux.common.Queue'
local MODS = require 'lux.pack' 'domain.modifiers'

-- CONSTANTS -------
local _QUEUE_LIMIT = 128

-- MODULE ----------
local MOD = {}

--[[
-- _absolute [tk] -> id [tk] -> attr [ti] -> mod [fn]
-- _relative [tk] -> id [tk] -> attr [ti] -> mod [fn]
--]]

-- LOCALS ----------
local _effects
local _dummy

-- LOCAL METHODS ---
local function _init()
  _effects = {
    absolute = {},
    relative = {},
  }
  _dummy = Queue(2)
  _dummy.push(DEFS.IDENTITY)
end

local function _newMod(type, strength, duration)
  return setmetatable({
    tick = 0,
    lifetime = duration,
  }, {
    __call = MODS[type](strength)
  })
end

local function _tick(target_fxs)
  if not target_fxs then return end
  for attr, modqueue in pairs(target_fxs) do
    modqueue.push(DEFS.DONE)
    local mod
    repeat
      mod = modqueue.pop()
      if mod ~= DEFS.DONE then
        mod.tick = mod.tick + 1
        if mod.tick < mod.lifetime then
          modqueue.push(mod)
        end
      end
    until mod == DEFS.DONE
  end
end

local function _runEffects(value, queue)
  queue.push(DEFS.DONE)
  local f
  repeat
    f = queue.pop()
    if f ~= DEFS.DONE then
      value = f(value)
      queue.push(f)
    end
  until f == DEFS.DONE
  return value
end

local function _findFXQueue(type, id, attr)
  local fxs = _effects[type][id]
  if not fxs then return _dummy end
  return fxs[attr] or _dummy
end

local function _findEffects(target, attr)
  local id = target:getId()
  local abs = _findFXQueue("absolute", id, attr)
  local rel = _findFXQueue("relative", id, attr)
  return abs, rel
end

-- PUBLIC METHODS --
function MOD.new(target, attr, type, strength, duration)
  (_effects and DEFS.NOTHING or _init)()
  local id = target:getId()
  local group = type == "set" and "absolute" or "relative"
  local target_fx = _effects[group][id] or {}
  local attr_fx = target_fx[attr] or Queue(_QUEUE_LIMIT)
  attr_fx.push(_newMod(type, strength, duration))
  target_fx[attr] = attr_fx
  _effects[group][id] = target_fx
end

function MOD.apply(target, attr, value)
  (_effects and DEFS.NOTHING or _init)()
  local id = target:getId()
  local abs, rel = _findEffects(target, attr)
  value = _runEffects(value, abs)
  value = _runEffects(value, rel)
  return value
end

function MOD.tick(target)
  (_effects and DEFS.NOTHING or _init)()
  local id = target:getId()
  _tick(_effects.absolute[id])
  _tick(_effects.relative[id])
end

function MOD:saveState()
end

function MOD:loadState(state)
end

return MOD

