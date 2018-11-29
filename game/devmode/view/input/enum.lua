
local IMGUI = require 'imgui'
local DB = require 'database'

local _NONE = "<none>"

local inputs = {}

function inputs.enum(spec, field)

  -- Build option list from given array or from a database domain
  local _options = field.options
  if type(_options) == 'string' then
    local group_name = _options
    local category, group = group_name:match("(.-)[%./](.+)")
    _options = { _NONE }
    for k,v in DB.listItemsIn(category, group) do
      table.insert(_options, k)
    end
    table.sort(_options)
  else
    _options = { _NONE }
    for k,v in ipairs(field.options) do
      table.insert(_options, v)
    end
  end

  -- Find the index of the currently assigned option
  local _current = 1
  for i,option in ipairs(_options) do
    if option == spec[field.id] then
      _current = i
      break
    end
  end

  local _active = not (not spec[field.id] and field.optional)

  if _active and _options[_current] ~= _NONE then
    spec[field.id] = spec[field.id] or _options[_current]
  else
    spec[field.id] = false
  end

  return function(gui)
    if field.optional then
      IMGUI.PushID(field.id .. ".check")
      _active = IMGUI.Checkbox("", _active)
      IMGUI.PopID()
      IMGUI.SameLine()
    end
    IMGUI.Text(field.name)
    if _active then
      IMGUI.PushID(field.id)
      local value, changed = IMGUI.Combo("", _current, _options, #_options, 15)
      IMGUI.PopID()
      if changed then
        _current = value
        if _options[value] == _NONE then
          spec[field.id] = false
        else
          spec[field.id] = _options[value]
        end
      end
    end
  end
end

return inputs

