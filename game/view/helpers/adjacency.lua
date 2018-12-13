local ADJACENCY = {}

function ADJACENCY.unset(adjacency)
  for i = 1, 3 do
    adjacency[i] = -1
  end
end

function ADJACENCY.update(adjacency, route, dir)
  local i, j = route.getControlledActor():getPos()
  local sector = route.getCurrentSector()
  local changed = false
  local side1, side2
  if dir[1] ~= 0 and dir[2] ~= 0 then
    side1 = {0, dir[2]}
    side2 = {dir[1], 0}
  elseif dir[1] == 0 then
    side1 = {-1, dir[2]}
    side2 = { 1, dir[2]}
  elseif dir[2] == 0 then
    side1 = {dir[1], -1}
    side2 = {dir[1],  1}
  end
  local range = {dir, side1, side2}

  for idx, adj_move in ipairs(range) do
    local ti = adj_move[1] + i
    local tj = adj_move[2] + j
    local tile = sector:isInside(ti, tj) and sector:getTile(ti, tj)
    local tile_type = tile and tile.type
    local current = adjacency[idx]
    adjacency[idx] = tile_type
    if current ~= -1 then
      if tile_type ~= current then
        changed = true
      end
    end
  end

  return changed
end

return ADJACENCY
