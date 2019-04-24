
local IMGUI       = require 'imgui'
local DB          = require 'database'
local IDGenerator = require 'common.idgenerator'
local class       = require 'lux.class'

local table = table
local ipairs = ipairs
local setfenv = setfenv

local _CMDTYPES = {
  'inputs', 'effects',
  inputs = "Input",
  effects = "Effect"
}

local _idgen = IDGenerator()

local AbilityEditor = class:new()

function AbilityEditor:instance(obj, _elementspec, _fieldschema)

  setfenv(1, obj)

  local _ability = _elementspec[_fieldschema.id] or
                   { inputs = {}, effects = {} }
  local _selected = nil
  local _active = not (not _elementspec[_fieldschema.id] and
                           _fieldschema.optional)

  local function _delete()
    table.remove(_ability[_selected.cmdtype], _selected.idx)
  end

  local function _commandList(gui, cmdtype)

    local result
    local cmdoptions = {}
    local cmdtypes = {}

    local list = _ability[cmdtype] or {}
    _ability[cmdtype] = list

    for _,option in DB.subschemaTypes(cmdtype) do
      table.insert(cmdoptions, option)
      table.insert(cmdtypes, cmdtype:sub(1,-2))
    end

    for _,option in DB.subschemaTypes('operators') do
      table.insert(cmdoptions, option)
      table.insert(cmdtypes, 'operator')
    end

    IMGUI.Text(("%ss:"):format(_CMDTYPES[cmdtype]))
    IMGUI.Indent(20)
    for i,command in ipairs(list) do
      local view
      if command.output then
        view = ("%s -> [%s]"):format(command.name, command.output)
      else
        view = ("%2d: %s"):format(i, command.name)
      end
      IMGUI.PushID(("%s/%s:%d"):format(_ability, cmdtype, i))
      if IMGUI.Selectable(view,
                          _selected and _selected.cmdtype == cmdtype
                                    and _selected.idx == i) then
        _selected = _selected or {}
        _selected.cmdtype = cmdtype
        _selected.idx = i
        gui:push('specification_editor', command,
                 command.type .. 's/' .. command.name, _CMDTYPES[cmdtype],
                 _delete, nil, _ability)
      end
      IMGUI.PopID()
    end
    if IMGUI.Button("New " .. _CMDTYPES[cmdtype]) then
      gui:push(
        'list_picker', _CMDTYPES[cmdtype], cmdoptions,
        function (value)
          if value then
            local new = { type = cmdtypes[value], name = cmdoptions[value] }
            local schema = require('domain.'..new.type..'s.'..new.name).schema
            for _,subfield_schema in ipairs(schema) do
              if subfield_schema.type == 'output' then
                new[subfield_schema.id] = 'label'.._idgen.newID()
              end
            end
            table.insert(list, new)
            return true
          end
          return 0
        end
      )
    end
    IMGUI.Unindent(20)
  end

  function input(gui)
    if _fieldschema.optional then
      IMGUI.PushID(_fieldschema.id .. ".check")
      _active = IMGUI.Checkbox("", _active)
      IMGUI.PopID()
      IMGUI.SameLine()
    end
    IMGUI.Text(("%s"):format(_fieldschema.name))
    if _active then
      IMGUI.Indent(20)
      if _fieldschema.hint then
        IMGUI.Text(_fieldschema.hint)
      end
      for _,cmdtype in ipairs(_CMDTYPES) do
        _commandList(gui, cmdtype)
      end
      _elementspec[_fieldschema.id] = _ability
      IMGUI.Unindent(20)
    end
  end

  function __operator:call(gui)
    return obj.input(gui)
  end

end

return { ability = AbilityEditor }

