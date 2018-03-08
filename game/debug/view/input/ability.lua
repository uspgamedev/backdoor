
local IMGUI       = require 'imgui'
local DB          = require 'database'
local IDGenerator = require 'common.idgenerator'

local _CMDTYPES = {
  'params', 'operators', 'effects',
  params = "Parameter",
  operators = "Value",
  effects = "Effect"
}

local _idgen = IDGenerator()

local inputs = {}

local function _commandList(self, ability, cmdtype, selected, delete)

  local result
  local typeoptions = {}

  local list = ability[cmdtype] or {}

  for _,option in DB.subschemaTypes(cmdtype) do
    table.insert(typeoptions, option)
  end

  IMGUI.Text(("%ss:"):format(_CMDTYPES[cmdtype]))
  IMGUI.Indent(20)
  for i,command in ipairs(list) do
    local view
    if command.output then
      view = ("%s -> [%s]"):format(command.typename, command.output)
    else
      view = ("%2d: %s"):format(i, command.typename)
    end
    IMGUI.PushID(("%s/%s:%d"):format(ability, cmdtype, i))
    if IMGUI.Selectable(view,
                        selected and selected.cmdtype == cmdtype
                                 and selected.idx == i) then
      selected = selected or {}
      selected.cmdtype = cmdtype
      selected.idx = i
      self:push('specification_editor', command,
                cmdtype .. '/' .. command.typename, _CMDTYPES[cmdtype], delete,
                nil, ability)
    end
    IMGUI.PopID()
  end
  if IMGUI.Button("New " .. _CMDTYPES[cmdtype]) then
    self:push(
      'list_picker', _CMDTYPES[cmdtype], typeoptions,
      function (value)
        if value then
          local new = { typename = typeoptions[value] }
          local schema = require('domain.'..cmdtype..'.'..new.typename).schema
          for _,subfield in ipairs(schema) do
            if subfield.type == 'output' then
              new[subfield.id] = 'label'.._idgen.newID()
            end
          end
          table.insert(list, new)
          ability[cmdtype] = list
          return true
        end
        return 0
      end
    )
  end
  IMGUI.Unindent(20)
  return selected
end

function inputs.ability(spec, field)

  local ability = spec[field.id]
                  or { params = {}, operators = {}, effects = {} }
  local selected = nil

  local function delete()
    table.remove(ability[selected.cmdtype], selected.idx)
  end

  local _active = not (not spec[field.id] and field.optional)

  return function(self)
    if field.optional then
      IMGUI.PushID(field.id .. ".check")
      _active = select(2, IMGUI.Checkbox("", _active))
      IMGUI.PopID()
      IMGUI.SameLine()
    end
    IMGUI.Text(("%s"):format(field.name))
    if _active then
      IMGUI.Indent(20)
      if field.hint then
        IMGUI.Text(field.hint)
      end
      for _,cmdtype in ipairs(_CMDTYPES) do
        selected = _commandList(self, ability, cmdtype, selected, delete)
      end
      spec[field.id] = ability
      IMGUI.Unindent(20)
    end
  end
end

return inputs

