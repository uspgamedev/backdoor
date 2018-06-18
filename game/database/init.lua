
local json = require 'dkjson'
local SCHEMA = require 'lux.pack' 'database.schema'
local DEFS = require 'domain.definitions'
local FS = love.filesystem

local DB = {}


local _dbcache = {}
local _subschemas = {}

local function _fullpath(relpath)
  local srcpath = love.filesystem.getSource()
  return ("%s/%s"):format(srcpath, relpath)
end

function _loadSubschema(base)
  local fs = love.filesystem
  local sub = _subschemas[base]
  if not sub then
    sub = {}
    for _,file in ipairs(fs.getDirectoryItems("domain/" .. base)) do
      if file:match "^.+%.lua$" then
        file = file:gsub("%.lua", "")
        sub[file] = require('domain.' .. base .. '.' .. file).schema
        table.insert(sub, file)
      end
    end
    _subschemas[base] = sub
  end
  return sub
end

function _subschemaFor(base, branch)
  return _loadSubschema(base)[branch]
end

local function _loadCategory(category)
  return _dbcache[category]
end

local function _loadGroup(category, group_name)
  return _loadCategory(category)[group_name]
end

local function _loadDomainGroup(group)
  return _loadGroup('domains', group)
end

local function _loadResourceGroup(group)
  return _loadGroup('resources', group)
end

local function _loadSetting(setting)
  return _loadGroup('settings', setting)
end

local function _listFilesIn(relpath)
  local list = love.filesystem.getDirectoryItems(relpath)
  local entries = {}
  for i, filename in ipairs(list) do
    local basename = filename:match("^(.+)%.json$")
    if basename then
      table.insert(entries, basename)
    end
  end
  return ipairs(entries)
end

local function _deleteFile(relpath)
  -- We need os.remove and fullpath to write to files
  -- This only works in development mode
  if love.filesystem.getInfo(relpath, 'file') then
    local path = _fullpath(relpath)
    return os.remove(_fullpath(relpath))
  end
end

local function _loadFile(relpath)
  local file = assert(FS.newFile(relpath, 'r'))
  local data, _, err = json.decode((file:read())) -- drop second value
  file:close()
  return assert(data, err)
end

local function _writeFile(relpath, rawdata)
  -- We need io.open and fullpath to write to files
  -- This only works in development mode
  local file = assert(io.open(_fullpath(relpath), 'w'))
  local data = json.encode(rawdata, {indent = true})
  assert(file:write(data))
  return file:close()
end

local function _save(cache, basepath)
  -- check whether we are saving a group of files or a file
  if not getmetatable(cache).is_leaf then
    -- save group
    for group, subcache in pairs(cache) do
      local meta = getmetatable(subcache) or {}
      local item = meta.group or group
      local newbasepath = basepath.."/"..item
      _save(subcache, newbasepath)
    end
  else
    -- save file
    local filepath = basepath..".json"
    return assert(_writeFile(filepath, cache))
  end
end

local function _refresh(cache, basepath)
  -- check whether we are saving a group of files or a file
  if getmetatable(cache).is_leaf then return end
  -- save group
  for group, subcache in pairs(cache) do
    local meta = getmetatable(subcache) or {}
    local item = meta.group or group
    local newbasepath = basepath.."/"..item
    if subcache == DEFS.DELETE then
      cache[group] = nil
      _deleteFile(newbasepath..".json")
    else
      _refresh(subcache, newbasepath)
    end
  end
  -- HARD REFRESH --
  local group
  repeat
    group = next(cache)
    if group then cache[group] = nil end
  until next(cache) == nil
end

function _listItemsIn(category, group_name)
  local group = _loadGroup(category, group_name)
  local relpath = getmetatable(group).relpath
  local found = {}
  for _,name in _listFilesIn(relpath) do
    if group[name] and group[name] ~= DEFS.DELETE then
      found[name] = true
    end
  end
  for name,spec in pairs(group) do
    if spec ~= DEFS.DELETE then
      found[name] = true
    end
  end
  return pairs(found)
end

local function _metaSpec(spec, container, name)
  local path = ("%s/%s"):format(getmetatable(container).relpath, name)
  return {
    is_leaf = true,
    relpath = path,
    group = name,
    __index = function(self, key)
      local extends = rawget(self, "extends")
      if extends then
        return container[extends][key]
      end
    end
  }
end

local function _get(self, key)
  local fs = love.filesystem
  local path = ("%s/%s"):format(getmetatable(self).relpath, key)
  local meta = {relpath = path, group = key}
  local obj = setmetatable({}, meta)

  -- if directory
  if fs.getInfo(path, 'directory') then
    meta.__index = _get
    self[key] = obj
    return obj
  end

  -- if json file
  local filepath = path..".json"
  if fs.getInfo(filepath, 'file') then
    obj = _loadFile(filepath)
    DB.initSpec(obj, self, meta.group)
    self[key] = obj
    return obj
  end
end

function DB.initSpec(spec, container, name)
  return setmetatable(spec, _metaSpec(spec, container, name))
end

function DB.subschemaTypes(base)
  return ipairs(_loadSubschema(base))
end

function DB.schemaFor(domain_name)
  local base, branch = domain_name:match('^(.+)/(.+)$')
  if base and branch then
    return ipairs(_subschemaFor(base, branch))
  else
    return ipairs(SCHEMA[domain_name])
  end
end

function DB.loadCategory(category)
  return _loadCategory(category)
end

function DB.loadGroup(category, group_name)
  return _loadGroup(category, group_name)
end

function DB.loadDomain(domain_name)
  return _loadDomainGroup(domain_name)
end

function DB.listDomainItems(domain_name)
  return _listItemsIn('domains', domain_name)
end

function DB.loadSpec(domain_name, spec_name)
  return DB.loadDomain(domain_name)[spec_name]
end

function DB.loadSetting(setting_name)
  return _loadSetting(setting_name)
end

function DB.loadResourceGroup(res_type)
  return _loadResourceGroup(res_type)
end

function DB.loadResource(res_type, res_name)
  return _loadResourceGroup(res_type)[res_name]
end

function DB.loadResourcePath(res_type, res_name)
  local path = "assets/%s/%s"
  local filename = DB.loadResource(res_type, res_name).filename
  return path:format(res_type, filename)
end

function DB.listResourceItems(res_name)
  return _listItemsIn('resources', res_name)
end

function DB.listItemsIn(category, group)
  return _listItemsIn(category, group)
end

function DB.refresh(container)
  container = container or _dbcache
  local basepath = getmetatable(container).relpath
  _refresh(container, basepath)
end

function DB.save(container)
  container = container or _dbcache
  local basepath = getmetatable(container).relpath
  _refresh(container, basepath)
  _save(container, basepath)
end

function DB.init()
  local meta = {
    relpath = "database",
    group = "database",
    __index = _get,
  }
  setmetatable(_dbcache, meta)
end

return DB

