
extends "res://components/util/mapgen/step.gd"

var from_tile
var to_tile
var chance

func _init(from_tile, to_tile, chance):
  self.from_tile = from_tile
  self.to_tile = to_tile
  self.chance = chance

func apply(map, w, h):
  var map_grid = MapGrid.clone(map, w, h)
  for i in range(h):
    for j in range(w):
      if map_grid.is_tile(i, j, from_tile) and randf() < chance:
        map_grid.set_tile(i, j, to_tile)
  return map_grid
