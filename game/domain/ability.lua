
local FX = require 'lux.pack' 'domain.effects'
local OP = require 'lux.pack' 'domain.operators'
local IN = require 'lux.pack' 'domain.inputs'
local DB = require 'database'

local function _unref(ref, values)
  if type(ref) == 'string' then
    local n = ref:match '=(.+)'
    if n then
      return values[n]
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

local function _unrefFieldValues(cmd, values)
  local unrefd_field_values = {}
  for _,field in _fields(cmd) do
    unrefd_field_values[field.id] = _unref(cmd[field.id], values)
  end
  return unrefd_field_values
end

function ABILITY.checkInputs(ability, actor, inputvalues)
  local values = {}
  for _,cmd in ipairs(ability.inputs) do
    local unrefd_field_values = _unrefFieldValues(cmd, values)
    if cmd.type == 'input' then
      local inputspec = IN[cmd.name]
      if inputspec.isValid(actor, unrefd_field_values,
                           inputvalues[cmd.output]) then
        if cmd.output then
          values[cmd.output] = inputvalues[cmd.output]
        end
      else
        return false
      end
    elseif cmd.type == 'operator' then
      values[cmd.output] = OP[cmd.name].process(actor, unrefd_field_values)
    end
  end
  return true, values
end

local function _hashExpansion(match)
  local hash = tostring(match.ability) .. tostring(match.source)
  return hash
end

local function _matches(actor, match, field_values, applied)
  local ability = match.ability
  if (not applied or not applied[_hashExpansion(match)]) then
    return ABILITY.checkInputs(ability, actor, field_values)
  end
  return false
end

local function _getMatchedAbilities(actor, name, field_values, applied)
  for _, widget in actor:getBody():eachWidget() do
    for _, static_ability in widget:getStaticAbilities() do
      if static_ability['op'] == name then
        local match = {
          ability = static_ability['replacement-ability'],
          source = widget
        }
        local ok, new_values = _matches(actor, match, field_values, applied)
        if ok then
          match.new_values = new_values
          return match
        end
      end
    end
  end
end

local function _joinPreviousAbilities(previous_abilities)
  local apply = {}
  for k, v in pairs(previous_abilities or {}) do
    apply[k] = v
  end
  return apply
end

local _CMDLISTS = { 'inputs', 'effects' }
local _CMDMAP = { operator = OP, effect = FX }

-- TODO:
--  + Expanded ability can only import integer and string values from matching
--    command
--  + Implement queries?
function ABILITY.execute(ability, actor, inputvalues)
  -- Register map of values computed by inputs, operators, and effects
  local values = {}
  -- Matrix of abilities already applied to commands:
  --  applied[cmd][ability] == true
  --    if and only if
  --  cmd derived from an expansion of ability
  local applied = {}
  -- Output redirection map, used to send expanded values into the
  -- corresponding fields of the original command
  local redirect = {}
  -- First iterate over input commands, then effect commands
  for _,cmdlist in ipairs(_CMDLISTS) do
    -- Use a deque to store commands so we can "expand" them when a replacement
    -- effect occurs
    local deque = {}
    for _,cmd in ipairs(ability[cmdlist]) do
      table.insert(deque, cmd)
    end
    -- Keep executing until the deque finishes
    while #deque > 0 do
      local cmd = table.remove(deque, 1)
      local type, name = cmd.type, cmd.name
      local value
      -- Input commands just retrieve the value provided from elsewhere
      -- (e.g. a target selected by the user)
      if type == 'input' then
        value = inputvalues[cmd.output]
      -- Operator and effect commands can be replaced by static abilities
      elseif type == 'operator' or type == 'effect' then
        -- Map previous values to the command's input
        local unrefd_field_values = _unrefFieldValues(cmd, values)
        -- Grab abilities that might have expanded this command
        local applied_abilities = applied[cmd]
        -- Check if any ability on the actor replaces the command
        local match = _getMatchedAbilities(actor, name, unrefd_field_values,
                                           applied_abilities)
        -- In which case, we expand its effects
        if match then
          local expanded_ability = match.ability
          for k, v in pairs(match.new_values) do
            values[k] = v
          end
          for i, expanded_cmd in ipairs(expanded_ability['effects']) do
            -- Insert in the front side of the deque
            table.insert(deque, i, expanded_cmd)
            -- Mark as applied to avoid endless recursion
            local apply = _joinPreviousAbilities(applied_abilities)
            apply[_hashExpansion(match)] = true
            applied[expanded_cmd] = apply
            -- Register redirected output
            redirect[expanded_cmd] = cmd['output']
          end
        -- If the command is not expanded, process it normally.
        else
          local process = _CMDMAP[type][name].process
          value = process(actor, unrefd_field_values)
        end
      else
        return error("Invalid command type")
      end
      -- The resulting value is stored in the register "values" if an output
      -- is specified.
      if cmd.output then
        -- However, if that value has an output named "result" and this command
        -- came from an expanded ability, then the value is redirected to the
        -- output of the command that caused the expansion.
        if cmd.output == 'result' and redirect[cmd] then
          local redirected_output = redirect[cmd]
          values[redirected_output] = value
        else
          values[cmd.output] = value
        end
      end
    end
  end
end

local function _NOPREVIEW()
  return nil
end

function ABILITY.preview(ability, actor, inputvalues, capitalize)
  local values = {}
  for _,cmdlist in ipairs(_CMDLISTS) do
    for _,cmd in ipairs(ability[cmdlist]) do
      local prev, value
      local type, name = cmd.type, cmd.name
      local unrefd_field_values = _unrefFieldValues(cmd, values)
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
        values[cmd.output] = value(actor, unrefd_field_values)
      end
      local text = (prev or _NOPREVIEW)(actor, unrefd_field_values)
      if text then
        table.insert(values, text)
      end
    end
  end
  local preview = table.concat(values, ". ") .. "."
  if capitalize then
    return preview:gsub("^(%w)", string.upper)
  else
    return preview
  end
end

return ABILITY
