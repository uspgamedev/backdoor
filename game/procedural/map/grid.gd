
const Tiles     = preload("res://game/sector/tiles.gd")

const MapScene  = preload("res://game/sector/sector_view.gd")

var map = []
var width = 0
var height = 0

func _init(w, h, value):
  width = w
  height = h
  map.resize(h)
  for i in range(h):
    map[i] = []
    map[i].resize(w)
    for j in range(w):
      map[i][j] = value

static func clone(map, w, h):
  var map_grid = new(w, h, Tiles.EMPTY)
  for i in range(h):
    for j in range(w):
      map_grid.set_tile(i, j, map[i][j])
  return map_grid

func is_tile(i, j, value):
  if value == Tiles.ANY:
    return true
  if value == Tiles.ANY_BUT_WALL and map[i][j] != Tiles.WALL:
    return true
  return value == map[i][j]

func set_tile(i, j, value):
  map[i][j] = value

func apply_step(step):
  return step.apply(map, width, height)

func export_scene(assembler):
  var tiles = []
  tiles.resize(width * height)
  printt("exporting map...")
  # Add floors
  for i in range(width):
    for j in range(height):
      # FIXME
      if Tiles.is_floor(map[j][i]) or Tiles.is_wall(map[j][i]):
        tiles[i * width + j] = map[j][i]
      else:
        tiles[i * width + j] = Tiles.FLOOR
  assembler.set_sector_map(tiles, width, height)
