
local IMGUI = require 'imgui'
local DB = require 'database'
local class = require 'lux.class'

local setfenv = setfenv
local table = table
local ipairs = ipairs
local type = type

local _NONE = "<none>"

local EnumEditor = class:new()

function EnumEditor:instance(obj, _elementspec, _fieldschema)

  setfenv(1, obj)

  -- Build option list from given array or from a database domain
  local _options = _fieldschema.options
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
    for k,v in ipairs(_fieldschema.options) do
      table.insert(_options, v)
    end
  end

  -- Find the index of the currently assigned option
  local _current = 1
  for i,option in ipairs(_options) do
    if option == _elementspec[_fieldschema.id] then
      _current = i
      break
    end
  end

  local _active = not (not _elementspec[_fieldschema.id]
                       and _fieldschema.optional)

  if _active and _options[_current] ~= _NONE then
    _elementspec[_fieldschema.id] = _elementspec[_fieldschema.id]
                                 or _options[_current]
  else
    _elementspec[_fieldschema.id] = false
  end

  function input(gui)
    if _fieldschema.optional then
      IMGUI.PushID(_fieldschema.id .. ".check")
      _active = IMGUI.Checkbox("", _active)
      IMGUI.PopID()
      IMGUI.SameLine()
    end
    IMGUI.Text(_fieldschema.name)
    if _active then
      IMGUI.PushID(_fieldschema.id)
      local value, changed = IMGUI.Combo("", _current, _options, #_options, 15)
      IMGUI.PopID()
      if changed then
        _current = value
        if _options[value] == _NONE then
          _elementspec[_fieldschema.id] = false
        else
          _elementspec[_fieldschema.id] = _options[value]
        end
      end
    end
  end

  function __operator:call(gui)
    return obj.input(gui)
  end
end

return { enum = EnumEditor }

