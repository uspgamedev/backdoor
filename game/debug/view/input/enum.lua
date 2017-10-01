
local IMGUI = require 'imgui'
local DB = require 'database'

local inputs = {}

function inputs.enum(spec, key)

  -- Build option list from given array or from a database domain
  local _options = key.options
  if type(_options) == 'string' then
    local domain_name = _options
    _options = {}
    for k,v in DB.listDomainItems(domain_name) do
      table.insert(_options,k)
    end
    table.sort(_options)
  end

  -- Find the index of the currently assigned option
  local _current = 1
  for i,option in ipairs(_options) do
    if option == spec[key.id] then
      _current = i
      break
    end
  end

  local _active = not (not spec[key.id] and key.optional)

  return function(self)
    if key.optional then
      IMGUI.PushID(key.id .. ".check")
      _active = select(2, IMGUI.Checkbox("", _active))
      IMGUI.PopID()
      IMGUI.SameLine()
    end
    IMGUI.Text(key.name)
    if _active then
      IMGUI.PushID(key.id)
      local changed,value = IMGUI.Combo("", _current, _options, #_options, 15)
      IMGUI.PopID()
      if changed then
        _current = value
        spec[key.id] = _options[value]
      end
    end
  end
end

return inputs

