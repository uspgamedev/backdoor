
const Step = preload("res://components/util/mapgen/step.gd")

const MapScene = preload("res://scenes/map.gd")

var map_ = []
var width_ = 0
var height_ = 0

func _init(w, h, value):
  width_ = w
  height_ = h
  map_.resize(h)
  for i in range(h):
    map_[i] = []
    map_[i].resize(w)
    for j in range(w):
      map_[i][j] = value

static func clone(map, w, h):
  var map_grid = new(w, h, Step.EMPTY)
  for i in range(h):
    for j in range(w):
      map_grid.set_tile(i, j, map[i][j])
  return map_grid

func set_tile(i, j, value):
  map_[i][j] = value

func apply_step(step):
  return step.apply(map_, width_, height_)

func export_scene(assembler):
  var floors = []
  var walls = []
  floors.resize(width_ * height_)
  walls.resize(width_ * height_)
  for i in range(width_):
      for j in range(height_):
          walls[i*width_ + j] = map_[j][i]
          if map_[j][i] != Step.WALL:
            floors[i*width_ + j] = 0
          else:
            floors[i*width_ + j] = -1
  assembler.set_sector_map(floors, walls, width_, height_)
