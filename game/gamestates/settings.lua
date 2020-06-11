
local DB           = require 'database'
local INPUT        = require 'input'
local DIRECTIONALS = require 'infra.dir'
local PROFILE      = require 'infra.profile'
local PLAYSFX      = require 'helpers.playsfx'
local SettingsView = require 'view.settings'
local Draw         = require "draw"
local SoundTrack   = require 'view.soundtrack'

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
local _changes

local function _changeField(field, offset)
  local low, high = unpack(_schema[field]["range"])
  local step = _schema[field]["step"]
  local value = (_changes[field] or _original[field]) + offset * step
  _changes[field] = min(high, max(low, value))
  PROFILE.setPreference(field, _changes[field])
  SoundTrack.get():setVolumeToPreference()
end

function state:init()
  _schema = DB.loadSetting("user-preferences")
  _fields = {}
  for field in pairs(_schema) do
    insert(_fields, field)
  end
  sort(_fields) -- show them in alphabetical order!
  _fieldcount = #_fields
  _selection = 1
end

function state:enter(from)
  _selection = 1
  _original = {}
  for _,field in ipairs(_fields) do
    _original[field] = PROFILE.getPreference(field) or _schema[field].default
    PROFILE.setPreference(field, _original[field])
  end
  _changes = setmetatable({}, { __index = original })
  _view = SettingsView(_fields)
  _view:register("GUI")
end

function state:update(dt)
  if INPUT.wasActionPressed("CONFIRM") then
    PLAYSFX('ok-menu', .05)
    _save = true
    SWITCHER.pop()
  elseif INPUT.wasActionPressed("CANCEL")
      or INPUT.wasActionPressed("PAUSE") then
    PLAYSFX('back-menu', .05)
    _save = false
    SWITCHER.pop()
  elseif DIRECTIONALS.wasDirectionTriggered("UP") then
    PLAYSFX('select-menu', .1)
    _selection = (_selection - 2 + _fieldcount) % _fieldcount + 1
    _view:setFocus(_selection)
  elseif DIRECTIONALS.wasDirectionTriggered("DOWN") then
    PLAYSFX('select-menu', .1)
    _selection = (_selection % _fieldcount) + 1
    _view:setFocus(_selection)
  elseif DIRECTIONALS.wasDirectionTriggered("LEFT") then
    PLAYSFX('ok-menu', .05)
    _changeField(_fields[_selection], -1)
  elseif DIRECTIONALS.wasDirectionTriggered("RIGHT") then
    PLAYSFX('ok-menu', .05)
    _changeField(_fields[_selection], 1)
  end

end

function state:leave()
  -- when you leave, it will either save or restore the changes
  if _save then
    PROFILE.save()
  else
    for field, value in pairs(_original) do
      PROFILE.setPreference(field, value)
    end
    SoundTrack.get():setVolumeToPreference()
  end
  _view:destroy()
end

function state:draw()
  return Draw.allTables()
end

return state
