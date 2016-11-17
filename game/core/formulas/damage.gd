
var base
var count
var sides
var attribute

func _init(base, count, sides, attribute):
  self.base = base
  self.count = count
  self.sides = sides
  self.attribute = attribute

func roll(actor):
  var value = 0
  for i in range(self.count):
    value += 1 + int(rand_range(0, self.sides))
  return self.base + value + actor.get_attribute(self.attribute)
