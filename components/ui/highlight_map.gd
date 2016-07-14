
extends TileMap

const AOE = 1

func add_area(pos, format, offset, id):
  for i in format.size():
    for j in format[i].size():
      var p = pos - offset + Vector2(j,i)
      set_cellv(p, format[i][j]*id)
