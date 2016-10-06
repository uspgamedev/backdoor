
extends "res://components/util/mapgen/step.gd"

const THREAD_NUM = 4

var window
var where
var which
var min_count
var max_count
var sem

func _init(where, which, min_count, max_count, size):
  self.where = where
  self.which = which
  self.min_count = min_count
  self.max_count = max_count
  window = []
  window.resize(size*size)
  for i in range(size):
    for j in range(size):
      window[i*size + j] = Vector2(i - size/2, j - size/2)

func apply_part(args):
  var map = args[0]
  var grid = args[1]
  var j0 = args[2]
  var i0 = args[3]
  var w = args[4]
  var h = args[5]
  for i in range(i0, i0+h):
    for j in range(j0, j0+w):
      grid.set_tile(i, j, map[i][j])
      if grid.is_tile(i, j, where):
        var count = 0
        for d in window:
          var tile = map[i + d.x][j + d.y]
          if tile == which:
            count += 1
        if count >= min_count and count <= max_count:
          grid.set_tile(i, j, which)

# override
func apply(map, w, h):
  var map_grid = MapGrid.new(w, h, EMPTY)
  var threads = range(THREAD_NUM)
  for i in range(THREAD_NUM):
    threads[i] = Thread.new()
  sem = Semaphore.new()
  sem.post()
  for i in range(THREAD_NUM-1):
    threads[i].start(self, "apply_part", [map, map_grid, 1, 1+i*h/THREAD_NUM, w-2, h/THREAD_NUM])
  threads[THREAD_NUM-1].start(self, "apply_part", [map, map_grid, 1, 1+(THREAD_NUM-1)*h/THREAD_NUM, w-2, h/THREAD_NUM-2])
  for i in range(THREAD_NUM):
    threads[i].wait_to_finish()
  sem = null
  return map_grid
