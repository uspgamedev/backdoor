
local JSON         = require 'dkjson'
local INPUT        = require 'input'

local IDGenerator  = require 'common.idgenerator'
local RUNFLAGS     = require 'infra.runflags'
local ROUTEBUILDER = require 'domain.builders.route'
local DB           = require 'database'
local ZIP          = love.math

-- CONSTANTS --
local SAVEDIR = "_savedata/"
local PROFILE_FILENAME = "profile"
local CONTROL_FILENAME = "controls"
local PROFILE_PATH = SAVEDIR..PROFILE_FILENAME
local CONTROL_PATH = SAVEDIR..CONTROL_FILENAME
local METABASE = { next_id = 1, save_list = {}, preferences = {} }

-- HELPERS
local filesystem = love.filesystem

-- LOCALS --
local PROFILE = {}
local __COMPRESS__ = false
local _id_generator
local _metadata

local function _compress(str) --> str
  if not __COMPRESS__ then return str end
  return assert(ZIP.compress(str:gsub(" ", ""), "lz4", 9))
end

local function _decompress(str) --> str
  if not __COMPRESS__ then return str end
  return assert(ZIP.decompress(str, "lz4"))
end

local function _encode(t) --> str
  return _compress(JSON.encode(t, {indent = true}))
end

local function _decode(str) --> table
  return JSON.decode(_decompress(str))
end

local function _deleteInput()
  INPUT.delete(CONTROL_PATH)
end

local function _loadInput()
  -- setup input
  local loaded_input = INPUT.load(CONTROL_PATH, _decode)
  if not loaded_input then
    local inputmap = DB.loadSetting('controls')
    INPUT.setup(inputmap)
  end
end

local function _saveInput()
  return INPUT.save(CONTROL_PATH, _encode)
end

local function _cleanSlate ()
  print("CLEAR FLAG SET. DELETING ALL SAVE DATA.")
  print("Removing custom controls")
  _deleteInput()
  for _,filename in ipairs(filesystem.getDirectoryItems(SAVEDIR)) do
    print(("Removing: %s"):format(filename))
    filesystem.remove(SAVEDIR..filename)
  end
end

local function _saveProfile(base)
  local profile_data = base or _metadata
  local file = assert(filesystem.newFile(PROFILE_PATH, "w"))
  file:write(_encode(profile_data))
  return file:close()
end

local function _newProfile()
  filesystem.createDirectory(SAVEDIR)
  _saveProfile(METABASE)
end

local function _loadProfile()
  local filedata = assert(filesystem.newFileData(PROFILE_PATH))
  _metadata = _decode(filedata:getString())
  _id_generator = IDGenerator(_metadata.next_id)
  for field, default in pairs(METABASE) do
    -- protection against version update (SHALLOW COPY ONLY)
    _metadata[field] = _metadata[field] or default
  end
end

-- METHODS --
function PROFILE.init()
  -- set version
  METABASE.version = VERSION
  -- clean all save history if CLEAR runflag is set
  __COMPRESS__ = __COMPRESS__ or RUNFLAGS.COMPRESS
  if RUNFLAGS.CLEAR then _cleanSlate() end
  -- check if profile exists and generate one if not
  if not filesystem.getInfo(PROFILE_PATH, 'file') then _newProfile() end
  -- load profile from disk
  _loadProfile()
  _loadInput()
end

function PROFILE.loadRoute(route_id)
  local filedata = assert(filesystem.newFileData(SAVEDIR..route_id))
  local route_data = _decode(filedata:getString())
  -- delete save from profile list
  _metadata.save_list[route_data.id] = nil
  return route_data
end

function PROFILE.saveRoute(route_data)
  local file = assert(filesystem.newFile(SAVEDIR..route_data.id, "w"))
  -- add save to profile list
  _metadata.save_list[route_data.id] = {
    player_name = route_data.player_name
  }
  file:write(_encode(route_data))
  return file:close()
end

function PROFILE.newRoute(player_info)
  local route_id = ("route%s"):format(_id_generator.newID())
  local route_data = ROUTEBUILDER.build(route_id, player_info)
  _metadata.next_id = _id_generator.getNextID()
  return route_data
end

function PROFILE.getSaveList()
  return _metadata.save_list
end

function PROFILE.getPreference(field)
  return _metadata.preferences[field]
end

function PROFILE.setPreference(field, value)
  _metadata.preferences[field] = value
end

function PROFILE.save()
  _saveProfile(_metadata)
end

-- NOTE TO SELF:
-- Add a quit method that deletes saves that are not on the profile's save_list.
-- This means that when you load a file, and you don't save it, it is lost
-- forever once the program quits. This would be an easy way to implement
-- permadeath. Also if you quit without saving, you lose your savefle.
-- BUT! If the game crashes, you keep your last save.
function PROFILE.quit()
  _saveInput()
  _saveProfile()
  local save_list = _metadata.save_list
  for _,filename in ipairs(filesystem.getDirectoryItems(SAVEDIR)) do
    if filename ~= PROFILE_FILENAME and filename ~= CONTROL_FILENAME
                                    and not save_list[filename] then
      print(("Removing unsaved file: %s"):format(filename))
      filesystem.remove(SAVEDIR..filename)
    end
  end
end


return PROFILE
