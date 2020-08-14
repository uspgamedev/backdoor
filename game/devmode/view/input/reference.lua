
local IMGUI = require 'imgui'
local class = require 'lux.class'

local setfenv = setfenv
local table = table
local ipairs = ipairs
local pairs = pairs
local require = require
local type = type
local tostring = tostring

local OutputEditor = class:new()

-- luacheck: no self
function OutputEditor:instance(obj, _elementspec, _fieldschema)

  setfenv(1, obj)

  function input(_) -- luacheck: no global
    IMGUI.PushID(_fieldschema.id)
    IMGUI.Text(_fieldschema.name)
    local value, changed = IMGUI.InputText("", _elementspec[_fieldschema.id]
                                            or _fieldschema.id, 64)
    if changed then
      _elementspec[_fieldschema.id] = value
    end
    IMGUI.PopID()
  end

  function __operator:call(gui) -- luacheck: no global
    return obj.input(gui)
  end
end

local ValueEditor = class:new()

function ValueEditor:instance(obj, _elementspec, _fieldschema, _parent)

  setfenv(1, obj)

  local inputInt = require 'devmode.view.helpers.integer'
  local inputStr = require 'devmode.view.helpers.string'

  local function _appendRefs(from, to, match)
    for _,item in pairs(from) do
      if item == _elementspec then return false end
      local t = require(('domain.%ss.%s'):format(item.type, item.name)).type
      if not t or not match or t == match then
        table.insert(to, "=" .. tostring(item.output))
      end
    end
    return true
  end

  local function _getRefs()
    local refs = {}
    _appendRefs(_parent.inputs, refs, _fieldschema.match)
    _appendRefs(_parent.effects, refs, _fieldschema.match)
    local idx = 0
    for i,ref in ipairs(refs) do
      if ref == _elementspec[_fieldschema.id] then
        idx = i
        break
      end
    end
    return refs, idx
  end

  local _value = 0
  local _refs, _idx = _getRefs()

  local _use_ref = true

  if  _fieldschema.match == 'integer' and
      type(_elementspec[_fieldschema.id]) == 'number' then
    _value = _elementspec[_fieldschema.id]
    _use_ref = false
  elseif _fieldschema.match == 'string' and
         type(_elementspec[_fieldschema.id]) == 'string' then
    _value = _elementspec[_fieldschema.id]
    _use_ref = false
  end

  function input(_) -- luacheck: no global
    IMGUI.PushID(_fieldschema.id)
    IMGUI.Text(_fieldschema.name)
    local changed
    if _use_ref then
      _idx, changed = IMGUI.Combo(_fieldschema.name, _idx, _refs, #_refs, 15)
      if changed then
        _elementspec[_fieldschema.id] = _refs[_idx]
      end
    else
      if _fieldschema.match == "integer" then
        _value, changed = inputInt(_value, "", _fieldschema.range)
      elseif _fieldschema.match == 'string' then
        _value, changed = inputStr(_value, "")
      end
      if changed then
        _elementspec[_fieldschema.id] = _value
      end
    end

    if _fieldschema.match == 'integer' or _fieldschema.match == 'string' then
      IMGUI.SameLine()
      _use_ref, _ = IMGUI.Checkbox("Ref##".._fieldschema.id, _use_ref)
    end
    IMGUI.PopID()
  end

  function __operator:call(gui) -- luacheck: no global
    return obj.input(gui)
  end
end

return { output = OutputEditor, value = ValueEditor }

