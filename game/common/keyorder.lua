
-- helper type verifiers
local function istable(v)
  return type(v) == "table"
end

local function isstring(v)
  return type(v) == "string"
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
  local keys = {}
  for k in pairs(t) do
    if isstring(k) then -- let's only bother with strings
      table.insert(keys, k)
    end
  end
  table.sort(keys) -- lua's quicksort: should order keys alphabetically

  for _,key in ipairs(keys) do
    local v = t[key]
    if istable(v) then
      if istable(v[1]) then -- arraytable!
        for _,subkey in ipairs(sortedArrayTableKeys(v, seen)) do
          print(">"..subkey)
          table.insert(result, subkey)
        end
      else
        for _,subkey in ipairs(sortedTableKeys(v, seen)) do
          print(">"..subkey)
          table.insert(result, subkey)
        end
      end
    else
      print(">"..key)
      table.insert(result, key)
    end
  end

  return result
end

function sortedArrayTableKeys(a, seen)
  -- make sure we don't have a nested loop, or we'll be stuck forever here
  assert(not seen[a], "Nested table loop found when ordering keys")
  seen[a] = true

  -- result array
  local result = {}
  for i,v in ipairs(a) do
    if istable(v) then
      if istable(v[1]) then -- arraytable!
        for _,subkey in ipairs(sortedTableKeys(v, seen)) do
          print(">"..subkey)
          table.insert(result, subkey)
        end
      else
        for _,subkey in ipairs(sortedArrayTableKeys(v, seen)) do
          print(">"..subkey)
          table.insert(result, subkey)
        end
      end
    end
  end
  return result
end

return {
  getOrderedKeys = function(t)
    print("new table:")
    return sortedTableKeys(t, {})
  end
}

