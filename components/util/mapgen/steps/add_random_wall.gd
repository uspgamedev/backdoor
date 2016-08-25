
extends "res://components/util/mapgen/step.gd"

func apply(map, w, h):
  var map_grid = MapGrid.clone(map, w, h)
  var i = 1 + int(randf() * (h-1))
  var j = 1 + int(randf() * (w-1))
  map_grid.set_tile(i, j, WALL)
  print("Adding random wall tile:")
  print("[ " + str(i) + ", " + str(j) + " ]")
  return map_grid
