
local RANDOM        = require 'common.random'
local DIR           = require 'domain.definitions.dir'
local ACTIONDEFS    = require 'domain.definitions.action'
local ACTION        = require 'domain.action'
local CHOOSE_TARGET = require 'domain.inputs.choose_target'
local TILE          = require 'common.tile'

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
          nearest = {{i,j}}
        elseif dist == mindist then
          nearest[#nearest] = {i,j}
        end
      end
    end
  end
  return nearest
end

local function _towardsTarget(actor, target_pos)
  local i, j = actor:getPos()
  for _,dir in ipairs(DIR) do
    if dir == 'LEFT' and i == target_pos[1] and j > target_pos[2] then
      return DIR[dir]
    elseif dir == 'RIGHT' and i == target_pos[1] and j < target_pos[2] then
      return DIR[dir]
    elseif dir == 'UP' and j == target_pos[2] and i > target_pos[1] then
      return DIR[dir]
    elseif dir == 'DOWN' and j == target_pos[2] and i < target_pos[1] then
      return DIR[dir]
    end
  end
end

local function _nearestDir(actor, target_pos)
  local i, j = actor:getPos()
  local di, dj = target_pos[1] - i, target_pos[2] - j
  local max = -1
  local nearest
  for _,dir in ipairs(DIR) do
    local vec = DIR[dir]
    local align = vec[1] * di + vec[2] * dj
    if align > max then
      nearest = vec
      max = align
    end
  end
  return nearest
end

local function _findInputs(actor, target, target_pos, input_values, plays)
  local input_spec = ACTION.pendingInput(_PLAY_CARD, actor, input_values)
  if not input_spec then
    plays.n = plays.n + 1
    plays[plays.n] = _shallowCopy(input_values)
  else
    if input_spec.name == 'choose_target' then
      local tactical_hint = input_spec['tactical-hint']
      input_values.tactical_hint = tactical_hint
      if tactical_hint == 'harmful' and
         CHOOSE_TARGET.isWithinRange(actor, input_values, target_pos) then
        input_values[input_spec.output] = target_pos
        return _findInputs(actor, target, target_pos, input_values, plays)
      elseif tactical_hint == 'helpful' or tactical_hint == 'healing' then
        input_values[input_spec.output] = { actor:getPos() }
        return _findInputs(actor, target, target_pos, input_values, plays)
      elseif tactical_hint == 'movement' then
        local from = { actor:getPos() }
        local range = input_spec['max-range']
        local sector = actor:getSector()
        local positions = _nearestPos(from, target_pos, range, sector)
        for _, pos in ipairs(positions) do
          input_values[input_spec.output] = pos
          _findInputs(actor, target, target_pos, input_values, plays)
        end
      end
    elseif input_spec.name == 'choose_dir' then
      local tactical_hint = input_spec['tactical-hint']
      input_values.tactical_hint = tactical_hint
      if tactical_hint == 'harmful' then
        local dir = _towardsTarget(actor, target_pos)
        if dir then
          input_values[input_spec.output] = dir
          return _findInputs(actor, target, target_pos, input_values, plays)
        end
      elseif tactical_hint == 'helpful' or tactical_hint == 'healing' then
        local dir_idx = RANDOM.generate(4)
        input_values[input_spec.output] = DIR[DIR[dir_idx]]
        return _findInputs(actor, target, target_pos, input_values, plays)
      elseif tactical_hint == 'movement' then
        local dir = _nearestDir(actor, target_pos)
        input_values[input_spec.output] = dir
        _findInputs(actor, target, target_pos, input_values, plays)
      end
    end
  end
end

local function listCardPlays(actor, target, target_pos)
  local plays = { n = 0 }
  for i = 1, actor:getHandSize() do
    local input_values = { card_index = i }
    _findInputs(actor, target, target_pos, input_values, plays)
  end
  return plays
end

return listCardPlays

