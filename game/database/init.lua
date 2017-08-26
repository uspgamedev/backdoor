
local json = require 'dkjson'
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'
local SCHEMA = require 'lux.pack' 'database.schema'

local DB = {}

-- Pending issues:
-- + Support range inputs (min + length)
-- + Use range input to min/max pairs in transformers
-- + 'list' should actually be 'mixedlist'

local domains = {}

local spec_meta = {}

function spec_meta:__index(key)
  local extends = rawget(self, "extends")
  if extends then
    return domains[extends][key]
  end
end

function DB.schemaFor(domain_name)
  local base, branch = domain_name:match('^(.+)/(.+)$')
  if base and branch then
    return ipairs(SCHEMA[base][branch])
  else
    return ipairs(SCHEMA[domain_name])
  end
end

function DB.loadDomain(domain_name)
  local domain = domains[domain_name] if not domain then
    -- FIXME: hardcoded base path
    local filepath = ("game/database/%s.json"):format(domain_name)
    local file = assert(io.open(filepath, 'r'))
    local _, err
    domain, _, err = json.decode(file:read('*a'))
    file:close()
    assert(domain, err)
    for k,spec in pairs(domain) do
      setmetatable(spec, spec_meta)
    end
    domains[domain_name] = domain
  end
  return domain
end

function DB.loadSpec(domain_name, spec_name)
  return DB.loadDomain(domain_name)[spec_name]
end

function DB.save()
  for name,domain in pairs(domains) do
    local filepath = ("game/database/%s.json"):format(name)
    local file = assert(io.open(filepath, 'w'))
    local data = json.encode(domain, { indent = true })
    file:write(data)
    file:close()
  end
end

return DB

