
local function istable(v)
  return type(v) == "table"
end

local function isstring(v)
  return type(v) == "string"
end

local function orderedKeys(t, seen)
  -- make sure we don't have a nested loop, or we'll be stuck forever here
  assert(not seen[t], "Nested table loop found when ordering keys")
  seen[t] = true

  -- iterate keys and add them
  local keys = {}
  for k, v in pairs(t) do
    if isstring(k) then -- let's only bother with strings
      table.insert(keys, k)
      if istable(v) then
        for _,kk in ipairs(orderedKeys(v, seen)) do
          table.insert(keys, kk)
        end
      end
    end
  end
  table.sort(keys) -- lua's quicksort: should order keys alphabetically
  return keys
end

return {
  getOrderedKeys = function(t)
    return orderedKeys(t, {})
  end
}

