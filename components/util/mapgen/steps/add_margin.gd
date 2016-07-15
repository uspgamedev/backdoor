
extends "res://components/util/mapgen/step.gd"

const MARGIN = 16

func apply(map, w, h):
  var nw = w + 2*MARGIN
  var nh = h + 2*MARGIN
  var map_grid = MapGrid.new(nw, nh, WALL)
  for i in range(h):
    for j in range(w):
      map_grid.set_tile(MARGIN + 1 + i, MARGIN + 1 + j, map[i][j])
  return map_grid
