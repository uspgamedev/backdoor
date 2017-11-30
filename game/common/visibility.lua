--Function that manipulate an actor's field of view
local SCHEMATICS = require 'domain.definitions.schematics'

--LOCAL FUNCTIONS DECLARATIONS--

local updateOctant
local newShadowLine
local isShadowLineFull
local newShadow
local shadowContainsAnother
local visibilityOfShadow
local addProjection
local transformOctant
local projectTile

local funcs = {}


function funcs.purgeActorFov(actor, sector)
  local w, h = sector:getDimensions()
  actor.fov = actor.fov or {}
  for i = 1, h do
    actor.fov[i] = actor.fov[i] or {}
    for j = 1, w do
      actor.fov[i][j] = false -- Invisible and not seen
    end
  end
end

--Reset actor field of view based on a given sector
function funcs.resetActorFov(actor, sector)

  local w, h = sector:getDimensions()
  actor.fov = actor.fov or {}
  for i = 1, h do
    actor.fov[i] = actor.fov[i] or {}
    for j = 1, w do
      if actor.fov[i][j] then
        actor.fov[i][j] = 0 -- Invisible but seen
      end
    end
  end

end

--Update actors field of view based on his position in a given sector
function funcs.updateFov(actor, sector)
  funcs.resetActorFov(actor, sector)
  for octant = 1, 8 do
    updateOctant(actor, sector, octant)
  end
end

-------------------
--LOCAL FUNCTIONS--
-------------------

function updateOctant(actor, sector, octant)
  local line = newShadowLine()
  local full_shadow = false

  --Actor current position
  local actor_i, actor_j = actor:getPos()

  local row = 0
  while true do

    local d_i, d_j = transformOctant(row, 0, octant)
    local pos = {actor_i + d_i, actor_j + d_j}

    --Check if tile is inside sector
    if not sector:isInside(pos[1],pos[2]) then break end
    if row > actor:getFov() then
      full_shadow = true
    end

    for col = 0, row do
      local d_i, d_j = transformOctant(row, col, octant)
      local pos = {actor_i + d_i, actor_j + d_j}

      --Check if tile is inside sector
      if not sector:isInside(pos[1],pos[2]) then break end

      if full_shadow then
        if actor.fov[pos[1]][pos[2]] then --Was seen once
          actor.fov[pos[1]][pos[2]] = 0 --Make it invisible
        end
      else
        --Set visibility of tile
        local projection = projectTile(row, col)
        local visible = 1 - visibilityOfShadow(line, projection)
        if actor.fov[pos[1]][pos[2]] or visible == 1  then
          actor.fov[pos[1]][pos[2]] = visible
        end

        --Add any wall tiles to the shadow line
        if visible == 1 and
           sector.tiles[pos[1]][pos[2]] and
           sector.tiles[pos[1]][pos[2]].type == SCHEMATICS.WALL then
              addProjection(line, projection)
              fullShadow = fullShadow or isShadowLineFull(line)
        end
      end
    end
    row = row + 1
  end
end

--Create an empty shadow line table
function newShadowLine()
  return {shadow_list = {}}
end

--Checks if a shadow line is complete from start to end
function isShadowLineFull(shadow_line)
    local list = shadow_line.shadow_list
    return (#list == 1 and list[1].start == 0 and list[1].finish == 1)
end

local MAX = 80

function printShadowLine(shadow_line)
  local string = {}
  for i=1,MAX do
    string[i] = '.'
  end
  for _,shadow in ipairs(shadow_line.shadow_list) do
    local a,b = shadow.start*MAX,shadow.finish*MAX
    a = math.floor(a + 0.5)
    b = math.floor(b + 0.5)
    for i=a,b do
      string[i] = 'X'
    end
  end
  print(table.concat(string))
end

--Create a shadow table
function newShadow(_start, _finish)
  assert(_start, "start argument not valid for new shadow")
  assert(_finish, "finish argument not valid for new shadow")
  return {
            start = _start,
            finish = _finish
         }
end

--Checks if a shadow completly contains another and
-- returns the ratio other shadow is covered
function shadowContainsAnother(shadow, other_shadow)

  --Is completly contained
  if other_shadow.finish <= shadow.finish and
     other_shadow.start >= shadow.start then
       return 1
  else
       return 0
  end

end

--Returns how visible is a projection given a line of shadows
--From 0 (visible) to 1 (not visible)
function visibilityOfShadow(shadow_line, projection)
    for _,shadow in ipairs(shadow_line.shadow_list) do
      if shadowContainsAnother(shadow, projection) == 1 then
        return 1
      end
    end

    return 0
end

function addProjection(line, projection)
  local list = line.shadow_list
  local index = 1;

  --Figure out where to slot the new shadow in the list
  while index <= #list do
     --Stop when we hit the insertion point.
     if list[index].start >= projection.start then break end
     index = index + 1
  end

  --Check if projection overlaps the previous or next shadow
  local overlappingPrevious
  if index > 1 and list[index - 1].finish > projection.start then
    overlappingPrevious = list[index - 1]
  end

  local overlappingNext
  if index <= #list and list[index].start < projection.finish then
    overlappingNext = list[index]
  end

  --Insert and unify with overlapping shadows.
  if overlappingNext then
    if overlappingPrevious then
      --Overlaps both, so unify one and delete the other.
      overlappingPrevious.finish = overlappingNext.finish
      table.remove(list,index)
    else
       --Overlaps the next one, so unify it with that.
       overlappingNext.start = projection.start
    end
  else
    if overlappingPrevious then
      --Overlaps the previous one, so unify it with that.
      overlappingPrevious.finish = projection.finish
    else
      --Does not overlap anything, so insert.
      table.insert(list, index, projection)
    end
  end

end

--Transforms row and column values to correspondent octant
function transformOctant(row, col, octant)
  if     octant == 1 then
    return col, -row
  elseif octant == 2 then
    return row, -col
  elseif octant == 3 then
    return  row,  col
  elseif octant == 4 then
    return  col,  row
  elseif octant == 5 then
    return -col,  row
  elseif octant == 6 then
    return -row,  col
  elseif octant == 7 then
    return -row, -col
  elseif octant == 8 then
    return -col, -row
  else
    error("not a valid octant value:"..octant)
  end
end

--Create a shadow correspondent to the projected silhouette of given tile
function projectTile(row, col)
  local top_left = col/(row+2)
  local bottom_right = (col+1)/(row+1)
  return newShadow(top_left, bottom_right)
end

return funcs
