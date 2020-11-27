
-- luacheck: globals love VERSION

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
local CONF_PATH = "conf.lua"
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
local _last_route_state

PROFILE.PREFERENCE = {
  AUTOSAVE = 'autosave-frequency',
  BGM_VOLUME = 'bgm-volume',
  SFX_VOLUME = 'sfx-volume'
}

PROFILE.MAX_AUTOSAVE = 100

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

local function _updateConf()
  print("Updating conf file...")
  --If first time, will create a new conf file on save directory
  if not filesystem.getInfo(CONF_PATH, 'file') then
    print("No internal conf file found. Creating new conf file...")

    local default_conf_data, err = love.filesystem.read("data", "conf.lua")
    assert(default_conf_data, "Error while trying to open default conf.lua file. Error message:\n"..tostring(err))

    local file = assert(filesystem.newFile(CONF_PATH, "w"), "Couldn't create new conf.file")
    local success, message = file:write(default_conf_data:clone())
    assert(success, "Error while writing to new conf file; Error message:\n"..tostring(message))
    file:close()
    print("Created new conf file!")
  end

  local file_data = ""
  local i = 1
  for line in love.filesystem.lines(CONF_PATH) do
    if i == 1 then
      file_data = file_data .. "--Internal conf file" .. "\r\n"
    else
      if line:find("fullscreen =") then
        local fullscreen = "= " ..tostring(PROFILE.getPreference("fullscreen") == "fullscreen")
        line = line:gsub("= (%w+)", fullscreen)
      end
      file_data = file_data .. line .. "\r\n"
    end
    i = i + 1
  end
  local success, message = love.filesystem.write(CONF_PATH, file_data)
  assert(success, "Error while writing to conf file. Error message:\n"..tostring(message))
  print("Updated conf file!")
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
  _last_route_state = route_data
end

function PROFILE.persistRoute()
  if not _last_route_state then return end
  -- add save to profile list
  _metadata.save_list[_last_route_state.id] = {
    player_name = _last_route_state.player_name,
    player_dead = _last_route_state.player_dead,
    player_won  = _last_route_state.player_won,
  }
  _channel:push({
    filepath = SAVEDIR .. _last_route_state.id,
    data = _last_route_state,
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

function PROFILE.getTutorial(field)
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
  _updateConf()
  -- politely ask for writing thread to die
  _channel:push({die = true})
  _savethread:wait()
  _savethread:release()
end

return PROFILE
