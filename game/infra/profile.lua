
local json = require 'dkjson'
local IDGenerator = require 'common.idgenerator'
local RUNFLAGS = require 'infra.runflags'
local ROUTEBUILDER = require 'infra.routebuilder'

-- CONSTANTS --
local SAVEDIR = "_savedata/"
local PROFILE_FILENAME = "profile"
local PROFILE_PATH = SAVEDIR..PROFILE_FILENAME
local METABASE = { next_id = 1, save_list = {} }

-- HELPERS
local filesystem = love.filesystem

-- LOCALS --
local PROFILE = {}
local _id_generator
local _metadata

local function _cleanSlate ()
  print("CLEAR FLAG SET. DELETING ALL SAVE DATA.")
  for _,filename in ipairs(filesystem.getDirectoryItems(SAVEDIR)) do
    print(("Removing: %s"):format(filename))
    filesystem.remove(SAVEDIR..filename)
  end
end

local function _newProfile()
  filesystem.createDirectory(SAVEDIR)
  local file, err = filesystem.newFile(PROFILE_PATH, "w")
  assert(file, err)
  local encoded = json.encode(METABASE)
  file:write(encoded)
  return file:close()
end

local function _saveProfile()
  local file, err = filesystem.newFile(PROFILE_PATH, "w")
  assert(file, err)
  local content = json.encode(_metadata)
  file:write(content)
  return file:close()
end

local function _loadProfile()
  local filedata, err = filesystem.newFileData(PROFILE_PATH)
  assert(filedata, err)
  _metadata = json.decode(filedata:getString())
  _id_generator = IDGenerator(_metadata.next_id)
end

-- METHODS --
function PROFILE.init()
  -- set version
  METABASE.version = VERSION
  -- clean all save history if CLEAR runflag is set
  if RUNFLAGS.CLEAR then _cleanSlate() end
  -- check if profile exists and generate one if not
  if not filesystem.exists(PROFILE_PATH) then _newProfile() end
  -- load profile from disk
  _loadProfile()
end

function PROFILE.loadRoute(route_id)
  local filedata, err = filesystem.newFileData(SAVEDIR..route_id)
  local route_data = json.decode(filedata:getString())
  -- delete save from list
  _metadata.save_list[route_data.route_id] = nil
  assert(filedata, err)
  return route_data
end

function PROFILE.saveRoute(route_data)
  local file, err = filesystem.newFile(SAVEDIR..route_data.route_id, "w")
  assert(file, err)
  -- add save to list
  -- Not that since we have the route's data in this scope, we can
  -- put a header in a profile header instead of just the value `true`.
  _metadata.save_list[route_data.route_id] = {
    charname = route_data.charname
  }
  file:write(json.encode(route_data))
  return file:close()
end

function PROFILE.newRoute()
  local route_id = ("route%s"):format(_id_generator.newID())
  local route_data = ROUTEBUILDER.build(route_id)
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
