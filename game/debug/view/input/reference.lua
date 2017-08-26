
local DB = require 'database'

local inputs = {}

local function _getRefs(spec, key, parent)
  local refs = {}
  for k,param in pairs(parent.params) do
    if param ~= spec then
      table.insert(refs, "par:" .. param.output)
    end
  end
  for k,value in pairs(parent.operators) do
    if value ~= spec then
      local t = require('domain.operators.'..value.typename).type
      if not t or t == key.match then
        table.insert(refs, "val:" .. value.output)
      end
    end
  end
  local idx = 0
  for i,ref in ipairs(refs) do
    if ref == spec[key.id] then
      idx = i
      break
    end
  end
  return refs, idx
end

inputs['output'] = function(spec, key, parent)
  return function(self)
    local changed, value = imgui.InputText(key.name, spec[key.id] or key.id, 64)
    if changed then
      spec[key.id] = value
    end
  end
end

inputs['value'] = function(spec, key, parent)

  local inputInt = require 'debug.view.helpers.integer'

  local value = 0
  local refs, idx = _getRefs(spec, key, parent)

  local use_ref = true

  if key.match == 'integer' and type(spec[key.id]) == 'number' then
    value = spec[key.id]
    use_ref = false
  end

  return function(self)
    local changed
    if use_ref then
      changed, idx = imgui.Combo(key.name, idx, refs, #refs, 5)
      if changed then
        spec[key.id] = refs[idx]
      end
    else
      value = inputInt(value, key.name, range)
      spec[key.id] = value
    end
    if key.match == 'integer' then
      imgui.SameLine()
      changed, use_ref = imgui.Checkbox("Ref##"..key.id, use_ref)
    end
  end
end

return inputs

