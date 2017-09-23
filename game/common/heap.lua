
local Prototype = require 'lux.prototype'

--HEAP--
local Heap = Prototype:new()

local function criterion(a, b)
  return a[2] < b[2]
end

function Heap:getNext()
  local len = #self.items
  local item = self.items[len]
  self.items[len] = nil
  return unpack(item)
end

function Heap:add(e, rank)
  rank = rank or 0
  table.insert(self.items, {e, rank})
  table.sort(self.items, criterion)
end

function Heap:isEmpty()
  return #self.items == 0
end

Heap.__init = {
  items = {},
}

return Heap

