
local ACTIONDEFS  = require 'domain.definitions.action'
local ACTION      = require 'domain.action'
local CHOOSE_TARGET = require 'domain.inputs.choose_target'
local TILE        = require 'common.tile'

local _PLAY_CARD = ACTIONDEFS.PLAY_CARD

local function _shallowCopy(input_values)
  local copy = {}
  for k,v in pairs(input_values) do
    copy[k] = v
  end
  return copy
end

local function _nearestPos(from, to, range, sector)
  local mindist = 999
  local nearest = nil
  for di = -range, range do
    for dj = -range, range do
      local i, j = from[1] + di, from[2] + dj
      if TILE.dist(0, 0, di, dj) <= range and sector:isValid(i, j) then
        local dist = TILE.dist(i, j, unpack(to))
        if dist < mindist then
          mindist = dist
          nearest = {i,j}
        end
      end
    end
  end
  return nearest
end

local function _findInputs(actor, target, target_pos, input_values, uses)
  local input_spec = ACTION.pendingInput(_PLAY_CARD, actor, input_values)
  if not input_spec then
    uses.n = uses.n + 1
    uses[uses.n] = _shallowCopy(input_values)
  else
    if input_spec.name == 'choose_target' then
      local tactical_hint = input_spec['tactical-hint']
      input_values.tactical_hint = tactical_hint
      if tactical_hint == 'harmful' and
         CHOOSE_TARGET.isWithinRange(actor, input_values, target_pos) then
        input_values[input_spec.output] = target_pos
        return _findInputs(actor, target, target_pos, input_values, uses)
      elseif tactical_hint == 'helpful' or tactical_hint == 'healing' then
        input_values[input_spec.output] = { actor:getPos() }
        return _findInputs(actor, target, target_pos, input_values, uses)
      elseif tactical_hint == 'movement' then
        local from = { actor:getPos() }
        local range = input_spec['max-range']
        input_values[input_spec.output] = _nearestPos(from, target_pos,
                                                      range, actor:getSector())
        return _findInputs(actor, target, target_pos, input_values, uses)
      end
    end
  end
end

local function listCardPlays(actor, target, target_pos)
  local uses = { n = 0 }
  for i = 1, actor:getHandSize() do
    local input_values = { card_index = i }
    _findInputs(actor, target, target_pos, input_values, uses)
  end
  return uses
end

return listCardPlays

