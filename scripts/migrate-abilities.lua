--------------------------------------------------------------------------------
-- This is script is used to migrate abilities in the database from 0.1's     --
-- system to 0.2's system                                                     --
--------------------------------------------------------------------------------

local json = require 'game.libs.dkjson'

local ins = { {'params', 'input'}, {'operators', 'operator'} }

local function migrateNode(node)
  if node['inputs'] then
    return node
  end
  local new = {}
  local names = {}
  new.inputs = {}
  for _,intype in ipairs(ins) do
    for i,param in ipairs(node[intype[1]]) do
      local input = {}
      input.type = intype[2]
      for k,field in pairs(param) do
        if k == 'typename' then
          input.name = field
        elseif type(field) == 'string' then
          local t,label = field:match('(%w+):(.+)')
          if t and label then
            input[k] = '=' .. label
          else
            input[k] = field
            if k == 'output' then
              assert(not names[field])
              names[field] = true
            end
          end
        else
          input[k] = field
        end
      end
      table.insert(new.inputs, input)
    end
  end
  new.effects = {}
  for i,param in ipairs(node['effects']) do
    local input = {}
    input.type = 'effect'
    for k,field in pairs(param) do
      if k == 'typename' then
        input.name = field
      elseif type(field) == 'string' then
        local t,label = field:match('(%w+):(.+)')
        if t and label then
          input[k] = '=' .. label
        else
          input[k] = field
          if k == 'output' then
            assert(not names[field])
            names[field] = true
          end
        end
      else
        input[k] = field
      end
    end
    table.insert(new.effects, input)
  end
  return new
end

local function scanNode(node)
  local changed = false
  for k,v in pairs(node) do
    if type(k) == 'string' and (k:match '.*ability.*' or
                                k:match 'trigger%-condition') then
      node[k] = migrateNode(v)
      changed = true
    elseif type(v) == 'table' then
      changed = scanNode(v)
    end
  end
  return changed
end

local function migrate(filename)
  print(("Updating %s"):format(filename))
  local f = io.open(filename, 'r')
  local data = json.decode(f:read('a'))
  f:close()
  if scanNode(data) then
    local out = json.encode(data, { indent = true })
    print(filename, "changed")
    print(out)
    f = io.open(filename, 'w')
    f:write(out)
    f:close()
  end
end

for line in io.lines() do
  migrate(line)
end

