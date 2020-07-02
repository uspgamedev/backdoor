
-- luacheck: no self

local ABILITY     = require 'domain.ability'
local IMGUI       = require 'imgui'
local DB          = require 'database'
local IDGenerator = require 'common.idgenerator'
local class       = require 'lux.class'

local table = table
local ipairs = ipairs
local require = require
local setfenv = setfenv
local pcall = pcall

local _CMDTYPES = {
  'inputs', 'effects',
  inputs = "Input",
  effects = "Effect"
}

local _idgen = IDGenerator()

local AbilityEditor = class:new()

-- luacheck: no self

local function _split(str, max_line_length)
  local lines = {}
  local line
  str:gsub(
    '(%s*)(%S+)',
    function(spc, word)
      if not line or #line + #spc + #word > max_line_length then
        table.insert(lines, line)
        line = word
      else
        line = line..spc..word
      end
    end
  )
  table.insert(lines, line)
  return lines
end

function AbilityEditor:instance(obj, _elementspec, _fieldschema)

  setfenv(1, obj)

  local _ability = _elementspec[_fieldschema.id] or
                   { inputs = {}, effects = {} }
  local _active = not (not _elementspec[_fieldschema.id] and
                           _fieldschema.optional)

  local _cmd_editors = {}
  local SPEC_EDITOR = require 'devmode.view.specification_editor'
  for _,cmdtype in ipairs(_CMDTYPES) do
    _cmd_editors[cmdtype] = {}
  end

  local function _bind_delete(cmdtype, i)
    return function ()
      table.remove(_ability[cmdtype], i)
      for _, editor in ipairs(_cmd_editors[cmdtype]) do
        editor.dirty = true
      end
    end
  end

  local function _editor_for(cmdtype, i)
    local cmd = _ability[cmdtype][i]
    local editor_list = _cmd_editors[cmdtype]
    if not editor_list[i] or editor_list[i].dirty then
      local _, _, renderer = SPEC_EDITOR(cmd, cmd.type .. 's/' .. cmd.name,
                                         _CMDTYPES[cmdtype],
                                         _bind_delete(cmdtype, i), nil,
                                         _ability)
      editor_list[i] = { render = renderer, dirty = false }
    end
    return editor_list[i]
  end

  local function _commandList(gui, cmdtype)

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
      local id = ("%s:%i"):format(command.name, i)
      if IMGUI.TreeNodeEx_2(id, { "Framed" }, view) then
        _editor_for(cmdtype, i).render(gui)
        IMGUI.TreePop()
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

  function input(gui) -- luacheck: no global
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
      IMGUI.Text("Preview")
      IMGUI.Indent(20)
      IMGUI.PushItemWidth(360)
      local ok, descr = pcall(ABILITY.preview,_ability, {}, {})
      if not ok then
        descr = "Could not preview ability"
      end
      local text = ""
      for _, line in ipairs(_split(descr, 40)) do
        text = text .. line .. "\n"
      end
      IMGUI.InputTextMultiline("", text, 1024, 0, 40, { "ReadOnly" })
      IMGUI.PopItemWidth()
      IMGUI.Unindent(40)
    end
  end

  function __operator:call(gui) -- luacheck: no global
    return obj.input(gui)
  end

end

return { ability = AbilityEditor }

