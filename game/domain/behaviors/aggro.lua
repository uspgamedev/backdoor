
local DIR = require 'domain.definitions.dir'
local Action = require 'domain.action'
local TILE = require 'common.tile'

return function (actor, sector)
  local actorlist = sector:getActors()
  local target, dist
  local i, j = actor:getPos()

  -- create list of opponents
  for _,opponent in ipairs(actorlist) do
    if opponent:isPlayer() then
      local k, l = opponent:getPos()
      local d = TILE.distUniform(i, j, k, l)
      if not target or not dist or d < dist then
        target = opponent
        dist = d
      end
    end
  end

  if dist == 1 then
    -- attack if close!
    return 'PRIMARY', { target = {target:getPos()} }
  elseif dist <= 4 then
    -- chase if far away!
    local ni, nj = i, j
    for n = 1, 4 do
      local di, dj = unpack(DIR[DIR[n]])
      local dist = TILE.distUniform(i, j, target:getPos())
      local newdist = TILE.distUniform(i+di, j+dj, target:getPos())
      if newdist < dist then
        ni = i + di
        nj = j + dj
      end
    end

    if sector:isValid(ni, nj) and (i ~= ni or j ~= nj) then
      return 'MOVE', { pos = {ni, nj} }
    end
  end

  return 'IDLE', {}
end

