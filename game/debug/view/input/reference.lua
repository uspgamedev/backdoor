
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

local function _getRefs(spec, field, parent)
  local refs = {}
  if _appendRefs(parent.params, refs, 'params', 'par', spec, field.match) then
    _appendRefs(parent.operators, refs, 'operators', 'val', spec, field.match)
  end
  local idx = 0
  for i,ref in ipairs(refs) do
    if ref == spec[field.id] then
      idx = i
      break
    end
  end
  return refs, idx
end

inputs['output'] = function(spec, field, parent)
  return function(gui)
    IMGUI.PushID(field.id)
    IMGUI.Text(field.name)
    local changed, value = IMGUI.InputText("", spec[field.id] or field.id, 64)
    if changed then
      spec[field.id] = value
    end
    IMGUI.PopID()
  end
end

inputs['value'] = function(spec, field, parent)

  local inputInt = require 'debug.view.helpers.integer'
  local inputStr = require 'debug.view.helpers.string'


  local value = 0
  local refs, idx = _getRefs(spec, field, parent)

  local use_ref = true

  if field.match == 'integer' and type(spec[field.id]) == 'number' then
    value = spec[field.id]
    use_ref = false
  elseif field.match == 'string' and type(spec[field.id]) == 'string' then
    value = spec[field.id]
    use_ref = false
  end

  return function(gui)
    IMGUI.PushID(field.id)
    IMGUI.Text(field.name)
    local changed
    if use_ref then
      changed, idx = IMGUI.Combo(field.name, idx, refs, #refs, 15)
      if changed then
        spec[field.id] = refs[idx]
      end
    else
      if field.match == "integer" then
        changed, value = inputInt(value, "", field.range)
      elseif field.match == 'string' then
        changed, value = inputStr(value, "")
      end
      if changed then
        spec[field.id] = value
      end
    end

    if field.match == 'integer' or field.match == 'string' then
      IMGUI.SameLine()
      changed, use_ref = IMGUI.Checkbox("Ref##"..field.id, use_ref)
    end
    IMGUI.PopID()

  end
end

return inputs
