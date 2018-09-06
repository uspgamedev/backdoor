
-- helper type verifiers
local function isstring(v)
  return type(v) == "string"
end

local function istable(v)
  return type(v) == "table"
end

local function arrayconcat(a1, a2)
  -- in place!
  local n = #a1 + 1
  for _,v in ipairs(a2) do
    a1[n] = v
    n = n + 1
  end
  return a1
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

local sortedTableKeys
local sortedArrayTableKeys

function sortedTableKeys(t, seen)
  -- make sure we don't have a nested loop, or we'll be stuck forever here
  assert(not seen[t], "Nested table loop found when ordering keys")
  seen[t] = true
  -- result array
  local result = {}
  -- iterate keys and add them
  local keys = tablekeys(t)
  table.sort(keys) -- lua's quicksort: should order keys alphabetically
  for _,key in ipairs(keys) do
    local v = t[key]
    table.insert(result, key)
    if istable(v) then
      if v[1] then
        result = arrayconcat(result, sortedArrayTableKeys(v, seen))
      else
        result = arrayconcat(result, sortedTableKeys(v, seen))
      end
    end
  end
  return result
end

function sortedArrayTableKeys(t, seen)
  -- make sure we don't have a nested loop, or we'll be stuck forever here
  assert(not seen[t], "Nested table loop found when ordering keys")
  seen[t] = true
  -- result array
  local result = {}
  for i,v in ipairs(t) do
    if istable(v) then
      if v[1] and istable(v[1]) then
        result = arrayconcat(result, sortedArrayTableKeys(v, seen))
      else
        result = arrayconcat(result, sortedTableKeys(v, seen))
      end
    end
  end
  return result
end

return {
  getOrderedKeys = function(t)
    print("new table:")
    return sortedTableKeys(t, {used = {}}, 0)
  end
}

