
local Prototype = require 'lux.prototype'

--HEAP--
local Heap = Prototype:new()

local function cmp(a, b)
  return a[2] < b[2]
end

local function maintain(self, i)
  local higher = false
  local left = 2*i
  local right = left+1

  if left <= self.size and cmp(self.items[left], self.items[i]) then
    higher = left
  else
    higher = i
  end

  if right <= self.size and cmp(self.items[right], self.items[higher]) then
    higher = right
  end

  if higher ~= i then
    local swap = self.items[i]
    self.items[i] = self.items[higher]
    self.items[higher] = swap
    maintain(self, higher)
  end
end

function Heap:getNext()
  local item = self.items[1]
  self.items[1] = self.items[self.size]
  self.items[self.size] = nil
  self.size = self.size - 1
  maintain(self, 1)
  return unpack(item)
end

function Heap:add(e, rank)
  rank = rank or 0
  self.size = self.size + 1
  self.items[self.size] = self.items[1]
  self.items[1] = {e, rank}
  maintain(self, 1)
end

function Heap:isEmpty()
  return #self.items == 0
end

Heap.__init = {
  items = {},
  size = 0,
}

return Heap

