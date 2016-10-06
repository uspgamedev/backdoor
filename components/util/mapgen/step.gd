
const MapGrid = preload("res://components/util/mapgen/map_grid.gd")

const EMPTY = -1
const FLOOR = 0
const WALL = 1
const WALL_TOP = 2
const WALL_TOP_RIGHT = 3
const WALL_RIGHT = 4
const WALL_BOTTOM_RIGHT = 5
const WALL_BOTTOM = 6
const WALL_BOTTOM_LEFT = 7
const WALL_LEFT = 8
const WALL_TOP_LEFT = 9
const WALL_CORNER_TOP_RIGHT = 10
const WALL_CORNER_BOTTOM_RIGHT = 11
const WALL_CORNER_BOTTOM_LEFT = 12
const WALL_CORNER_TOP_LEFT = 13
const FLOOR_DIRT = 14
const ANY = -2
const ANY_BUT_WALL = -3

# Override this method to produce a MapGrid from the given map
func apply(map, w, h):
  assert(false)

static func is_floor(value):
  return value == FLOOR or value == FLOOR_DIRT

static func is_wall(value):
  return value >= WALL and value <= WALL_CORNER_TOP_LEFT
