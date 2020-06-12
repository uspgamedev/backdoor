
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

-- TODO:
--  + Expanded ability can only import integer and string registers from matching
--    command
--  + Static abilities do not work on input checks or previews
--  + Implement queries?

-- Every helper function used here is either const or mutates only the values
-- it returns.
local _hashAbility, _matches, _matchAbilities, _copySourceAbilities,
      _importRegisters, _expandCommands, _redirectOutputs, _markSourceAbilities

--- Executes an ability from an actor using the provided input values.
--
--  Might match static abilities, causing the expansion of commands. This
--  happens whenever a command has the name indicated by an static ability and
--  its parameter values satisfy the input of that static ability. In this
--  case, the command is substituted by the sequence of effect commands in the
--  static ability.
--
--  Expanded commands have two nuances. First, registers written to by the
--  input commands of the static ability are imported into the current ability,
--  but name clashes raise an error. Second, expanded commands with output
--  name "result" are redirected to the orignally substituted command's output.
function ABILITY.execute(ability, actor, inputvalues)
  local registers = {}
  local src_abilities_of = {}
  local redirected_output = {}
  for _,cmdlist in ipairs(_CMDLISTS) do
    local cmd_stream = {}
    for i,cmd in ipairs(ability[cmdlist]) do
      cmd_stream[i] = cmd
    end
    while #cmd_stream > 0 do
      local cmd = table.remove(cmd_stream, 1)
      local value
      if cmd.type == 'input' then
        value = inputvalues[cmd.output]
      elseif _CMDMAP[cmd.type] then
        local derefd_field_values = _derefFieldValues(cmd, registers)
        local match = _matchAbilities(actor, cmd.name, derefd_field_values,
                                      src_abilities_of[cmd])
        if match then
          registers = _importRegisters(registers, cmd, match)
          cmd_stream = _expandCommands(cmd_stream, match)
          redirected_output = _redirectOutputs(redirected_output, match, cmd)
          src_abilities_of = _markSourceAbilities(src_abilities_of, match, cmd)
        else
          local process = _CMDMAP[cmd.type][cmd.name].process
          value = process(actor, derefd_field_values)
        end
      else
        return error("Invalid command type")
      end
      if cmd.output then
        if cmd.output == 'result' and redirected_output[cmd] then
          registers[redirected_output[cmd]] = value
        else
          registers[cmd.output] = value
        end
      end
    end
  end
end

local function _NOPREVIEW()
  return nil
end

function ABILITY.preview(ability, actor, inputvalues, capitalize)
  local registers = {}
  for _,cmdlist in ipairs(_CMDLISTS) do
    for _,cmd in ipairs(ability[cmdlist]) do
      local prev, value
      local type, name = cmd.type, cmd.name
      local derefd_field_values = _derefFieldValues(cmd, registers)
      if type == 'input' then
        value = IN[name].preview or function()
          return inputvalues[cmd.output]
        end
      else
        if type == 'operator' then
          value = OP[name].preview
        elseif type == 'effect' then
          prev = FX[name].preview
        else
          return error("Invalid command type")
        end
      end
      if cmd.output and value then
        registers[cmd.output] = value(actor, derefd_field_values)
      end
      local text = (prev or _NOPREVIEW)(actor, derefd_field_values)
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

-- Helper functions from here on

function _hashAbility(match)
  local hash = tostring(match.ability) .. tostring(match.source)
  return hash
end

function _matches(actor, match, field_values, src_abilities)
  local ability = match.ability
  if not (src_abilities and src_abilities[_hashAbility(match)]) then
    return ABILITY.checkInputs(ability, actor, field_values)
  end
  return false
end

function _matchAbilities(actor, cmd_name, field_values, src_abilities)
  for _, widget in actor:getBody():eachWidget() do
    for _, static_ability in widget:getStaticAbilities() do
      if static_ability['op'] == cmd_name then
        local match = {
          ability = static_ability['replacement-ability'],
          source = widget
        }
        local ok, new_values = _matches(actor, match, field_values,
                                        src_abilities)
        if ok then
          match.new_values = new_values
          return match
        end
      end
    end
  end
end

function _copySourceAbilities(src_abilities)
  local copy = {}
  for k, v in pairs(src_abilities or {}) do
    copy[k] = v
  end
  return copy
end

local _OVERWRITE_MSG = [[
register %s overwritten by expansion of ability from card %s on command %s!]]

function _importRegisters(registers, cmd, match)
  for k, v in pairs(match.new_values) do
    assert(not registers[k],
           _OVERWRITE_MSG:format(k, match.source:getName(), cmd.name))
    registers[k] = v
  end
  return registers
end

function _expandCommands(cmd_stream, match)
  for i, expanded_cmd in ipairs(match.ability['effects']) do
    table.insert(cmd_stream, i, expanded_cmd)
  end
  return cmd_stream
end

function _redirectOutputs(redirected_output, match, cmd)
  for _, expanded_cmd in ipairs(match.ability['effects']) do
    redirected_output[expanded_cmd] = cmd['output']
  end
  return redirected_output
end

function _markSourceAbilities(src_abilities_of, match, cmd)
  for _, expanded_cmd in ipairs(match.ability['effects']) do
    local src_abilities = _copySourceAbilities(src_abilities_of[cmd])
    src_abilities[_hashAbility(match)] = true
    src_abilities_of[expanded_cmd] = src_abilities
  end
  return src_abilities_of
end

return ABILITY

