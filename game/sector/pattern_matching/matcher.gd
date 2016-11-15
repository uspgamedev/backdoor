
const Tiles = preload("res://game/sector/tiles.gd")

onready var rules = get_children()

func match(map_reader, i, j):
  for rule in self.rules:
    var result = rule.match(map_reader, i, j)
    if result != null:
      return result
  return null
