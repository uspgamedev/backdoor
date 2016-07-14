
extends TileMap

const AOE = 0

func _ready():
  printt("I'M A HIGHLIGHT MAP DAMMIT")

func add_area(pos, format, offset, id):
  for i in range(format.size()):
    for j in range(format[i].size()):
      if format[i][j] > 0:
        var p = pos - offset + Vector2(j,i)
        set_cellv(p, id)
