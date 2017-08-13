
local json = require 'dkjson'

local DB = {}

local SCHEMA = {
  body = {
    { id = 'extends', type = "enum", options = 'domain' },
    { id = 'hp', type = "integer", range = {1,999} }
  },
  actor = {
    { id = 'extends', type = "enum", options = 'domain' },
    { id = 'behavior', type = "enum", options = {'player','random_walk'} }
  }
}

local domains = {}

function DB.schemaFor(domain_name)
  return ipairs(SCHEMA[domain_name])
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
      setmetatable(spec, { __index = spec.extends })
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

