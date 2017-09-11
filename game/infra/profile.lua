
local json = require 'dkjson'
local lzw = require 'lualzw'
local IDGenerator = require 'common.idgenerator'
local RUNFLAGS = require 'infra.runflags'
local ROUTEBUILDER = require 'infra.routebuilder'
local INPUT = require 'infra.input'

-- CONSTANTS --
local SAVEDIR = "_savedata/"
local PROFILE_FILENAME = "profile"
local PROFILE_PATH = SAVEDIR..PROFILE_FILENAME
local METABASE = { next_id = 1, save_list = {} }

-- HELPERS
local filesystem = love.filesystem

-- LOCALS --
local PROFILE = {}
local __COMPRESS__ = false
local _id_generator
local _metadata

local function _compress(str) --> str
  if not __COMPRESS__ then return str end
  return assert(lzw.compress(str))
end

local function _decompress(str) --> str
  if not __COMPRESS__ then return str end
  return assert(lzw.decompress(str))
end

local function _encode(t) --> str
  return _compress(json.encode(t, {indent = true}))
end

local function _decode(str) --> table
  return json.decode(_decompress(str))
end

local function _cleanSlate ()
  print("CLEAR FLAG SET. DELETING ALL SAVE DATA.")
  for _,filename in ipairs(filesystem.getDirectoryItems(SAVEDIR)) do
    print(("Removing: %s"):format(filename))
    filesystem.remove(SAVEDIR..filename)
  end
end

local function _saveProfile(base)
  local profile_data = base or _metadata
  local file = assert(filesystem.newFile(PROFILE_PATH, "w"))
  profile_data.key_mapping = INPUT.getMapping()
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
  INPUT.loadMapping(_metadata.key_mapping)
end

-- METHODS --
function PROFILE.init()
  -- set version
  METABASE.version = VERSION
  -- clean all save history if CLEAR runflag is set
  __COMPRESS__ = __COMPRESS__ or RUNFLAGS.COMPRESS
  if RUNFLAGS.CLEAR then _cleanSlate() end
  -- check if profile exists and generate one if not
  if not filesystem.exists(PROFILE_PATH) then _newProfile() end
  -- load profile from disk
  _loadProfile()
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
  print(("Generating %s..."):format(route_id))
  print(("Seed: %d"):format(route_data.rng_seed))
  print(("RNG state: %d"):format(route_data.rng_state))
  return route_data
end

function PROFILE.getSaveList ()
  return _metadata.save_list
end

-- NOTE TO SELF:
-- Add a quit method that deletes saves that are not on the profile's save_list.
-- This means that when you load a file, and you don't save it, it is lost
-- forever once the program quits. This would be an easy way to implement
-- permadeath. Also if you quit without saving, you lose your savefle.
-- BUT! If the game crashes, you keep your last save.
function PROFILE.quit()
  _saveProfile()
  local save_list = _metadata.save_list
  for _,filename in ipairs(filesystem.getDirectoryItems(SAVEDIR)) do
    if filename ~= PROFILE_FILENAME and not save_list[filename] then
      print(("Removing unsaved file: %s"):format(filename))
      filesystem.remove(SAVEDIR..filename)
    end
  end
end


return PROFILE
