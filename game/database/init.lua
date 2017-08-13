
local json = require 'dkjson'
local DB = {}

local domains = {}

function DB.loadSpec(domain_name, spec_name)
  local domain = domains[domain_name] if not domain then
    -- FIXME: hardcoded base path
    local filepath = ("game/database/%s.json"):format(domain_name)
    local file = assert(io.open(filepath, 'r'))
    local _, err
    domain, _, err = json.decode(file:read('*a'))
    assert(domain, err)
    file:close()
    for k,spec in pairs(domain) do
      setmetatable(spec, { __index = spec.extends })
    end
    domains[domain_name] = domain
  end
  return domain[spec_name]
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

