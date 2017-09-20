
local IMGUI = require 'imgui'
local DB = require 'database'

local inputs = {}

local function _appendRefs(from, to, dir, tag, spec, match)
  for k,item in pairs(from) do
    if item == spec then return false end
    local t = require(('domain.%s.%s'):format(dir, item.typename)).type
    if not t or t == match then
      table.insert(to, tag .. ":" .. item.output)
    end
  end
  return true
end

local function _getRefs(spec, key, parent)
  local refs = {}
  if _appendRefs(parent.params, refs, 'params', 'par', spec, key.match) then
    _appendRefs(parent.operators, refs, 'operators', 'val', spec, key.match)
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
    IMGUI.Text(key.name)
    local changed, value = IMGUI.InputText("", spec[key.id] or key.id, 64)
    if changed then
      spec[key.id] = value
    end
  end
end

inputs['value'] = function(spec, key, parent)

  local inputInt = require 'debug.view.helpers.integer'
  local inputStr = require 'debug.view.helpers.string'


  local value = 0
  local refs, idx = _getRefs(spec, key, parent)

  local use_ref = true

  if key.match == 'integer' and type(spec[key.id]) == 'number' then
    value = spec[key.id]
    use_ref = false
  elseif key.match == 'string' and type(spec[key.id]) == 'string' then
    value = spec[key.id]
    use_ref = false
  end

  return function(self)
    IMGUI.Text(key.name)
    local changed
    if use_ref then
      changed, idx = IMGUI.Combo(key.name, idx, refs, #refs, 15)
      if changed then
        spec[key.id] = refs[idx]
      end
    else
      if key.match == "integer" then
        changed, value = inputInt(value, "", key.range)
      elseif key.match == 'string' then
        changed, value = inputStr(value, "")
      end
      if changed then
        spec[key.id] = value
      end
    end

    if key.match == 'integer' or key.match == 'string' then
      IMGUI.SameLine()
      changed, use_ref = IMGUI.Checkbox("Ref##"..key.id, use_ref)
    end

  end
end

return inputs
