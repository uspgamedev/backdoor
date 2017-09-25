
local Prototype = require 'lux.prototype'

--HEAP--
local Heap = Prototype:new()

local function cmp(a, b)
  return a[2] < b[2]
end

local function maintain(array, i)
  local parent = math.floor(i/2)

  if parent > 0 and cmp(array[parent], array[i]) then
    local swap = array[i]
    array[i] = array[parent]
    array[parent] = swap
    maintain(array, parent)
  end
end

function Heap:getNext()
  local item = self.items[self.size]
  self.items[self.size] = nil
  self.size = self.size - 1
  maintain(self.items, self.size)
  return unpack(item)
end

function Heap:add(e, rank)
  rank = rank or 0
  self.size = self.size + 1
  self.items[self.size] = {e, rank}
  maintain(self.items, self.size)
end

function Heap:isEmpty()
  return #self.items == 0
end

Heap.__init = {
  items = {},
  size = 0,
}

return Heap

