
local FX = require 'lux.pack' 'domain.effects'
local OP = require 'lux.pack' 'domain.operators'
local IN = require 'lux.pack' 'domain.inputs'
local DB = require 'database'

local function _deref(ref, registers)
  if type(ref) == 'string' then
    local n = ref:match '=(.+)'
    if n then
      return registers[n]
    end
  end
  return ref
end

local ABILITY = {}

function ABILITY.allOperationsAndEffects()
  local t = {}
  local n = 1
  for _,option in DB.subschemaTypes('operators') do
    t[n] = option
    n = n + 1
  end
  for _,option in DB.subschemaTypes('effects') do
    t[n] = option
    n = n + 1
  end
  return t
end

function ABILITY.inputsOf(ability)
  return ipairs(ability.inputs)
end

function ABILITY.input(input_name)
  return IN[input_name]
end

function ABILITY.validate(input_name, actor, input_fields, value)
  return IN[input_name].isValid(actor, input_fields, value)
end

local function _fields(cmd)
  return DB.schemaFor(cmd.type .. 's/' .. cmd.name)
end

local function _derefFieldValues(cmd, registers)
  local derefd_field_values = {}
  for _,field in _fields(cmd) do
    derefd_field_values[field.id] = _deref(cmd[field.id], registers)
  end
  return derefd_field_values
end

function ABILITY.checkInputs(ability, actor, inputvalues)
  local registers = {}
  for _,cmd in ipairs(ability.inputs) do
    local derefd_field_values = _derefFieldValues(cmd, registers)
    if cmd.type == 'input' then
      local inputspec = IN[cmd.name]
      if inputspec.isValid(actor, derefd_field_values,
                           inputvalues[cmd.output]) then
        if cmd.output then
          registers[cmd.output] = inputvalues[cmd.output]
        end
      else
        return false
      end
    elseif cmd.type == 'operator' then
      registers[cmd.output] = OP[cmd.name].process(actor, derefd_field_values)
    end
  end
  return true, registers
end

local _CMDLISTS = { 'inputs', 'effects' }
local _CMDMAP = { operator = OP, effect = FX }

local function _matchStatic(actor, cmd_name)
  local matches = {}
  local n = 1
  for _, widget in actor:getBody():eachWidget() do
    for _, static_ability in widget:getStaticAbilities() do
      if static_ability['op'] == cmd_name then
        matches[n] = static_ability['replacement-ability']
        n = n + 1
      end
    end
  end
  return ipairs(matches)
end

local function _applyStaticAbilities(actor, cmd_name, field_values)
  for _, ability in _matchStatic(actor, cmd_name) do
    if ABILITY.checkInputs(ability, actor, field_values) then
      field_values = ABILITY.execute(ability, actor, field_values)
    end
  end
  return field_values
end

--- Executes an ability from an actor using the provided input values.
--
--  Might match static abilities, which means other these other abilities will
--  have a chance to alter the field values used to process a matched command.
function ABILITY.execute(ability, actor, registers)
  for _,cmdlist in ipairs(_CMDLISTS) do
    for _,cmd in ipairs(ability[cmdlist]) do
      local value
      if cmd.type == 'input' then
        value = registers[cmd.output]
      elseif _CMDMAP[cmd.type] then
        local field_values = _derefFieldValues(cmd, registers)
        field_values = _applyStaticAbilities(actor, cmd.name, field_values)
        local process = _CMDMAP[cmd.type][cmd.name].process
        value = process(actor, field_values)
      else
        return error("Invalid command type")
      end
      if cmd.output then
        registers[cmd.output] = value
      end
    end
  end
  return registers
end

local function _NOPREVIEW()
  return nil
end

function ABILITY.preview(ability, actor, registers, capitalize)
  for _,cmdlist in ipairs(_CMDLISTS) do
    for _,cmd in ipairs(ability[cmdlist]) do
      local prev, value
      local type, name = cmd.type, cmd.name
      local field_values = _derefFieldValues(cmd, registers)
      if type == 'input' then
        value = IN[name].preview or function()
          return registers[cmd.output]
        end
      else
        field_values = _applyStaticAbilities(actor, cmd.name, field_values)
        if type == 'operator' then
          value = OP[name].preview
        elseif type == 'effect' then
          prev = FX[name].preview
        else
          return error("Invalid command type")
        end
      end
      if cmd.output and value then
        registers[cmd.output] = value(actor, field_values)
      end
      local text = (prev or _NOPREVIEW)(actor, field_values)
      if text then
        table.insert(registers, text)
      end
    end
  end
  local preview = table.concat(registers, ". ") .. "."
  if capitalize then
    return preview:gsub("^(%w)", string.upper)
  else
    return preview
  end
end

return ABILITY

