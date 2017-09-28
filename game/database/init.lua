
local json = require 'dkjson'
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'
local SCHEMA = require 'lux.pack' 'database.schema'

local DB = {}

local _dbcache = {
  domains = {},
  settings = {},
  resources = {},
}

local function _metaSpec(domain_name)
  return {
    __index = function(self, key)
      local extends = rawget(self, "extends")
      if extends then
        return DB.loadSpec(domain_name, extends)[key]
      end
    end
  }
end

local subschemas = {}

function _loadSubschema(base)
  local fs = love.filesystem
  local sub = subschemas[base]
  if not sub then
    sub = {}
    for _,file in ipairs(fs.getDirectoryItems("domain/" .. base)) do
      if file:match "^.+%.lua$" then
        file = file:gsub("%.lua", "")
        sub[file] = require('domain.' .. base .. '.' .. file).schema
        table.insert(sub, file)
      end
    end
    subschemas[base] = sub
  end
  return sub
end

function _subschemaFor(base, branch)
  return _loadSubschema(base)[branch]
end

local function _loadGroup(category, group_name)
  local group = _dbcache[category][group_name] if not group then
    -- FIXME: hardcoded base path
    local filepath = ("game/database/%s/%s.json"):format(category, group_name)
    local file = assert(io.open(filepath, 'r'))
    local _, err
    group, _, err = json.decode(file:read('*a'))
    file:close()
    assert(group, err)
    for k,spec in pairs(group) do
      DB.initSpec(spec, group_name)
    end
    _dbcache[category][group_name] = group
  end
  return group
end

function DB.initSpec(spec, domain_name)
  return setmetatable(spec, _metaSpec(domain_name))
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

local function _loadResource(resource_type)
  return _loadGroup("resources", resource_type)
end

function DB.loadDomain(domain_name)
  return _loadGroup("domains", domain_name)
end

function DB.loadSpec(domain_name, spec_name)
  return DB.loadDomain(domain_name)[spec_name]
end

function DB.loadSetting(setting_name)
  return _loadGroup("settings", setting_name)
end

function DB.loadResourcePath(resource_type, resource_name)
  local filename = _loadResource(resource_type)[resource_name].filename
  return "assets/"..resource_type.."/"..filename
end

function DB.save()
  for name,domain in pairs(_dbcache.domains) do
    local filepath = ("game/database/domains/%s.json"):format(name)
    local file = assert(io.open(filepath, 'w'))
    local data = json.encode(domain, { indent = true })
    file:write(data)
    file:close()
  end
end

return DB

