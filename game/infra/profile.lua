
local json = require 'dkjson'
local IDGenerator = require 'common.idgenerator'
local RUNFLAGS = require 'infra.runflags'

-- CONSTANTS --
local SAVEDIR = "_savedata/"
local PROFILE_FILENAME = SAVEDIR.."profile"
local METABASE = { next_id = 1, save_list = {} }

-- HELPERS
local filesystem = love.filesystem

-- LOCALS --
local PROFILE = {}
local _id_generator
local _metadata

local function _cleanSlate ()
  local savedir = filesystem.getSaveDirectory()
  print("CLEAR FLAG SET. DELETING ALL SAVE DATA.")
  for _,filename in ipairs(filesystem.getDirectoryItems(SAVEDIR)) do
    print(("Removing: %s"):format(filename))
    filesystem.remove(SAVEDIR..filename)
  end
end

local function _newProfile()
  filesystem.createDirectory(SAVEDIR)
  local file, err = filesystem.newFile(PROFILE_FILENAME, "w")
  assert(file, err)
  local encoded = json.encode(METABASE)
  file:write(encoded)
  return file:close()
end

-- METHODS --
function PROFILE.init()
  if RUNFLAGS.CLEAR then _cleanSlate() end
  -- check if profile exists
  if not filesystem.exists(PROFILE_FILENAME) then _newProfile() end

  -- load profile
  local filedata, err = filesystem.newFileData(PROFILE_FILENAME)
  assert(filedata, err)
  _metadata = json.decode(filedata:getString())
  _id_generator = IDGenerator(_metadata.next_id)
end

function PROFILE.save()
  local file, err = filesystem.newFile(PROFILE_FILENAME, "w")
  assert(file, err)
  file:write(json.encode(_metadata))
  return file:close()
end

function PROFILE.loadRoute(route_id)
  local filedata, err = filesystem.newFileData(SAVEDIR..route_id)
  assert(filedata, err)
  return json.decode(filedata:getString())
end

function PROFILE.saveRoute(route_data)
  local file, err = filesystem.newFile(SAVEDIR..route_data.route_id, "w")
  assert(file, err)
  table.insert(_metadata.save_list, route_data.route_id)
  file:write(json.encode(route_data))
  return file:close()
end

function PROFILE.newRoute()
  local id = ("route%s"):format(_id_generator.newID())
  _metadata.next_id = _id_generator.getNextID()
  print(("Generating %s..."):format(id))
  return route_id
end

function PROFILE.getSaveList ()
  return _metadata.save_list
end

return PROFILE
