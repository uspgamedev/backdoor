
extends TileMap

const RANGE = 0
const AOE = 1

func _ready():
  pass

func add_tile(pos, id):
  set_cellv(pos, id)

func add_area(pos, format, offset, id):
  for i in range(format.size()):
    for j in range(format[i].size()):
      if format[i][j] > 0:
        var p = pos - offset + Vector2(j,i)
        set_cellv(p, id)
