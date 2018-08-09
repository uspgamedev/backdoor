
local DB           = require 'database'
local INPUT        = require 'input'
local DIRECTIONALS = require 'infra.dir'
local PROFILE      = require 'infra.profile'
local PLAYSFX      = require 'helpers.playsfx'

local state = {}

local insert = table.insert
local sort = table.sort
local max = math.max
local min = math.min
local unpack = unpack

local _selection
local _schema
local _fields
local _fieldcount
local _original
local _view
local _save
local _soundtrack

local function _changeField(field, offset)
  local low, high = unpack(_schema[field]["range"])
  local step = _schema[field]["step"]
  local value = (_changes[field] or _original[field]) + offset * step
  _changes[field] = min(high, max(low, value))
  PROFILE.setPreference(field, _changes[field])
end

function state:init()
  _soundtrack = Util.findId("BGM-PLAYER")
  _schema = DB.loadSetting("user-preferences")
  _fields = {}
  for field in pairs(_schema) do
    insert(_fields, field)
  end
  sort(_fields) -- show them in alphabetical order!
  _fieldcount = #fields
  _selection = 0
end

function state:enter(from, ...)
  _selection = 0
  _original = {}
  for _,field in ipairs(_fields) do
    _original[field] = PROFILE.getPreference(field) or _schema[field].default
  end
  _changes = setmetatable({}, { __index = original })
end

function state:update(dt)
  if INPUT.wasActionPressed("CONFIRM") then
    PLAYSFX 'ok-menu'
    _save = true
    SWITCHER.pop()
  elseif INPUT.wasActionPressed("CANCEL") then
    PLAYSFX 'back-menu'
    _save = false
    SWITCHER.pop()
  elseif DIRECTIONALS.wasDirectionTriggered("UP") then
    PLAYSFX 'select-menu'
    _selection = (_selection - 2 + _fieldcount) % _fieldcount + 1
  elseif DIRECTIONALS.wasDirectionTriggered("DOWN") then
    PLAYSFX 'select-menu'
    _selection = (_selection % _fieldcount) + 1
  elseif DIRECTIONALS.wasDirectionTriggered("LEFT") then
    PLAYSFX 'ok-menu'
    local field = _fields[_selection]
    _changeField(field, -1)
  elseif DIRECTIONALS.wasDirectionTriggered("RIGHT") then
    PLAYSFX 'ok-menu'
    local field = _fields[_selection]
    _changeField(field, 1)
  end
end

function state:leave()
  -- when you leave, it will either save or restore the changes
  if _save then
    PROFILE.save()
    PROFILE.init()
  else
    for field, value in ipairs(_original) do
      PROFILE.setPreference(field, value)
    end
  end
  _soundtrack.updateVolume()
end

function state:draw()
  return Draw.allTables()
end

return state

