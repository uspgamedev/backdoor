
extends "res://game/core/backdoor_node.gd"

const Tiles = preload("res://game/sector/tiles.gd")

const ZERO_VEC = Vector3(0,0,0)

const WINDOW = [
  Vector2(-1,-1),
  Vector2(-1,0),
  Vector2(-1,1),
  Vector2(0,-1),
  Vector2(0,0),
  Vector2(0,1),
  Vector2(1,-1),
  Vector2(1,0),
  Vector2(1,1)
]

var pattern_matrix

export(Matrix3) var pattern = Matrix3(ZERO_VEC, ZERO_VEC, ZERO_VEC)

func _ready():
  pattern_matrix = [
  [pattern.x.x, pattern.x.y, pattern.x.z],
  [pattern.y.x, pattern.y.y, pattern.y.z],
  [pattern.z.x, pattern.z.y, pattern.z.z],
  ]

func match(map_reader, i, j):
  for d in WINDOW:
    var tile = map_reader.call_func(i+d.y, j+d.x)
    var pat = pattern_matrix[d.y+1][d.x+1]
    if not ( pat == Tiles.ANY or tile == pat or (pat == Tiles.ANY_BUT_WALL and tile != Tiles.WALL) ):
      return false
  return true
