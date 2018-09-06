
-- helper type verifiers
local function isstring(v)
  return type(v) == "string"
end

local function istable(v)
  return type(v) == "table"
end

local function tablekeys(t)
  local keys = {}
  local n = 1
  for k in pairs(t) do
    if isstring(k) then
      keys[n] = k
      n = n + 1
    end
  end
  return keys
end

local addSortedKeys

function addSortedKeys(t, seen)
  -- make sure we don't have a nested loop, or we'll be stuck forever here
  if seen[t] then return end
  seen[t] = true
  local keys = tablekeys(t)
  table.sort(keys) -- lua's quicksort: should order keys alphabetically
  for k,v in pairs(t) do
    if istable(v) then
      addSortedKeys(v, seen)
    end
  end

  return setmetatable(t, { __jsonorder = keys })
end

return {
  setOrderedKeys = function(t)
    return addSortedKeys(t, {})
  end
}

