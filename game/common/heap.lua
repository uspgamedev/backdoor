
local Prototype = require 'lux.prototype'

--HEAP--
local Heap = Prototype:new()

local function cmp(a, b)
  return a[2] < b[2]
end

local function maintain_up(array, i)
  local parent = math.floor(i/2)

  if parent > 0 and cmp(array[parent], array[i]) then
    local swap = array[i]
    array[i] = array[parent]
    array[parent] = swap
    maintain_up(array, parent)
  end
end

local function maintain_down(array, i, limit)
  local left = i*2
  local right = left+1
  local higher = false

  if left <= limit and cmp(array[left], array[i]) then
    higher = left
  else
    higher = i
  end

  if right <= limit and cmp(array[right], array[i]) then
    higher = right
  end

  if higher ~= i then
    local swap = array[i]
    array[i] = array[higher]
    array[higher] = swap
    maintain_down(array, higher, limit)
  end
end

function Heap:getNext()
  local item = self.items[1]
  self.items[1] = self.items[self.size]
  self.items[self.size] = nil
  self.size = self.size - 1
  maintain_down(self.items, 1, self.size)
  return unpack(item)
end

function Heap:add(e, rank)
  rank = rank or 0
  self.size = self.size + 1
  self.items[self.size] = {e, rank}
  maintain_up(self.items, self.size)
end

function Heap:isEmpty()
  return #self.items == 0
end

Heap.__init = {
  items = {},
  size = 0,
}

return Heap

