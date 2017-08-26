
local DB = require 'database'

local inputs = {}

inputs['value/integer'] = function(spec, key, parent)

  local inputInt = require 'debug.view.helpers.integer'

  local idx = 0
  local value = 0

  local use_ref = false
  local refs = {}
  for k,param in pairs(parent.params) do
    table.insert(refs, "par:" .. param.output)
  end
  for k,value in pairs(parent.operators) do
    table.insert(refs, "val:" .. value.output)
  end

  if type(spec[key.id]) == 'number' then
    value = spec[key.id]
    use_ref = false
  else
    for i,ref in ipairs(refs) do
      if ref == spec[key.id] then
        idx = i
        use_ref = true
        break
      end
    end
  end

  return function(self)
    local changed
    changed, use_ref = imgui.Checkbox("Ref##"..key.id, use_ref)
    imgui.SameLine()
    if use_ref then
      changed, idx = imgui.Combo(key.name, idx, refs, #refs, 5)
      if changed then
        spec[key.id] = refs[idx]
      end
    else
      value = inputInt(value, key.name, range)
      spec[key.id] = value
    end
  end
end

return inputs

