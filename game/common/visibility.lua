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

--Reset actor field of view based on a given sector
function funcs.resetActorFov(actor, sector)

  local w, h = sector:getDimensions()
  actor.fov = {}
  for i = 1, h do
    actor.fov[i] = {}
    for j = 1, w do
      actor.fov[i][j] = 0 --Not visible
    end
  end

end

--Update actors field of view based on his position in a given sector
function funcs.updateFov(actor, sector)
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


  for row = 1, actor.fov_range do

    local d_i, d_j = transformOctant(row, 0, octant)
    local pos = {actor_i + d_i, actor_j + d_j}

    --Check if tile is inside sector
    if not sector:isInside(pos[1],pos[2]) then break end

    for col = 0, row do
      local d_i, d_j = transformOctant(row, col, octant)
      local pos = {actor_i + d_i, actor_j + d_j}

      --Check if tile is inside sector
      if not sector:isInside(pos[1],pos[2]) then break end

      if full_shadow then
        actor.fov[pos[1]][pos[2]] = 0 --Tile is not visible at all
      else
        --Set visibility of tile
        local projection = projectTile(row, col)
        local visible = visibilityOfShadow(line, projection)
        actor.fov[pos[1]][pos[2]] = visible

        --Add any wall tiles to the shadow line
        if visible > 0 and
           sector.tiles[pos[1]][pos[2]] and
           sector.tiles[pos[1]][pos[2]].type == SCHEMATICS.WALL then
              addProjection(line, projection)
              fullShadow = isShadowLineFull(line)
        end

      end

    end
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

--Create a shadow table
function newShadow(_start, _finish)
  assert(_start, "start argument not valid for new shadow")
  assert(_finish, "finish argument not valid for new shadow")
  return {
            start = _start,
            finish = _finish
         }
end

--Checks if a shadow completly contains another and returns the ratio
function shadowContainsAnother(shadow, other_shadow)

    --Case where other shadow is completly outside shadow
    if other_shadow.finish <= shadow.start or
       other_shadow.start >= shadow.finish then
         return 0
    end

    --Case where has some intersection
    local size = other_shadow.finish - other_shadow.start
    local outside_size = 0
    if other_shadow.start < shadow.start then
      outside_size = outside_size + (shadow.start-other_shadow.start)
    end
    if other_shadow.finish > shadow.finish then
      outside_size = outside_size + (other_shadow.finish-shadow.finish)
    end

    return outside_size/size
end

--Returns how visible is a projection given a line of shadows
--From 0 (not visible) to 1 (totally visible)
function visibilityOfShadow(shadow_line, projection)
    local ratio = 0
    for _,shadow in ipairs(shadow_line.shadow_list) do
      ratio = ratio + shadowContainsAnother(shadow, projection)
    end

    return 1 - ratio
end

function addProjection(line, projection)
  local list = line.shadow_list
  local index = 1;

  --Figure out where to slot the new shadow in the list
  for index = 1, #list do
     --Stop when we hit the insertion point.
     if list[index].start >= projection.start then break end
  end

  --Check if projection overlaps the previous or next shadow
  local overlappingPrevious
  if index > 1 and list[index - 1].finish > projection.start then
    overlappingPrevious = list[index - 1]
  end

  local overlappingNext
  if index < #list and list[index].start < projection.finish then
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
