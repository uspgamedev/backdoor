
local IMGUI = require 'imgui'
local DB = require 'database'

local inputs = {}

function inputs.enum(spec, key)

  -- Build option list from given array or from a database domain
  local _options = key.options
  if type(_options) == 'string' then
    local domain = DB.loadDomain(_options)
    _options = {}
    for k,v in pairs(domain) do
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
      _active = select(2, IMGUI.Checkbox("", _active))
      IMGUI.SameLine()
    end
    if _active then
      local changed,value = IMGUI.Combo(key.name, _current, _options, #_options,
                                        10)
      if changed then
        _current = value
        spec[key.id] = _options[value]
      end
    elseif key.optional then
      IMGUI.Text(key.name)
    end
  end
end

return inputs

