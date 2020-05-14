
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
local IO_THREAD_FILE = "infra/writingthread.lua"
local PROFILE_PATH = SAVEDIR..PROFILE_FILENAME
local CONTROL_PATH = SAVEDIR..CONTROL_FILENAME
local METABASE = { next_id = 1, save_list = {}, preferences = {}, tutorial = {}, unlockables = {}, }

-- HELPERS
local filesystem = love.filesystem

-- LOCALS --
local PROFILE = {}
local _id_generator
local _metadata
local _savethread
local _channel
local _confirm
local _compress

local function _decompress(str) --> str
  if not _compress then return str end
  return assert(ZIP.decompress(str, "lz4"))
end

local function _decode(str) --> table
  return JSON.decode(_decompress(str))
end

local function _deleteInput()
  return filesystem.remove(CONTROL_PATH)
end

local function _loadInput()
  local inputmap
  if filesystem.getInfo(CONTROL_PATH, { type = 'file' }) then
    local filedata = assert(filesystem.newFileData(CONTROL_PATH))
    inputmap = _decode(filedata:getString())
  else
    inputmap = DB.loadSetting('controls')
  end
  return INPUT.setup(inputmap)
end

local function _saveInput()
  local inputmap = INPUT.getMap()
  return _channel:push({
    filepath = CONTROL_PATH,
    data = inputmap,
    compress = _compress,
  })
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

local function _saveProfile(base, confirm)
  local profile_data = base or _metadata
  return _channel:push({
    filepath = PROFILE_PATH,
    data = profile_data,
    compress = _compress,
    confirm = confirm,
  })
end

local function _newProfile()
  filesystem.createDirectory(SAVEDIR)
  _saveProfile(METABASE, true)
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

  -- check whether we're compressing savedata
  _compress = not not RUNFLAGS.COMPRESS

  -- setup writing thread
  _channel = love.thread.getChannel('write_data')
  _confirm = love.thread.getChannel('confirm')
  _savethread = love.thread.newThread(IO_THREAD_FILE)
  _savethread:start()

  if RUNFLAGS.CLEAR then _cleanSlate() end
  -- check if profile exists and generate one if not
  if not filesystem.getInfo(PROFILE_PATH, 'file') then
    print("Creating new profile...")
    _newProfile()
    _confirm:demand()
    print("Created new profile!")
  end
  -- load profile from disk
  _loadProfile()
  _loadInput()
end

function PROFILE.loadRoute(route_id)
  local filedata = assert(filesystem.newFileData(SAVEDIR..route_id))
  local route_data = _decode(filedata:getString())
  return route_data
end

function PROFILE.saveRoute(route_data)
  -- add save to profile list
  _metadata.save_list[route_data.id] = {
    player_name = route_data.player_name,
    player_dead = route_data.player_dead,
    player_won  = route_data.player_won,
  }
  _channel:push({
    filepath = SAVEDIR .. route_data.id,
    data = route_data,
    compress = _compress,
  })
  return _saveProfile()
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
  local value = _metadata.preferences[field]
  if not value then
    local schema = DB.loadSetting("user-preferences")[field]
    value = schema.default
    PROFILE.setPreference(field, value)
  end
  return value
end

function PROFILE.setPreference(field, value)
  _metadata.preferences[field] = value
end

function PROFILE.getTutorial(field, value)
  local value = _metadata.tutorial[field]
  if not value then
    value = DB.loadSetting("tutorial")[field]
  end
  return value
end

function PROFILE.setTutorial(field, value)
  _metadata.tutorial[field] = value
end

function PROFILE.save()
  _saveProfile()
end

function PROFILE.quit()
  _saveInput()
  _saveProfile()
  -- politely ask for writing thread to die
  _channel:push({die = true})
  _savethread:wait()
  _savethread:release()
end

return PROFILE
