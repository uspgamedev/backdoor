
extends "res://game/procedural/map/step.gd"

const THREAD_NUM = 4

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

var rules_
var sem_

func _init(dict):
  rules_ = dict

static func load_from_file(pattern_name):
  var dict = {}
  var file = File.new()
  var text = ""
  file.open("res://game/procedural/map/patterns/" + pattern_name + ".json", File.READ)
  text = file.get_as_text()
  dict.parse_json(text)
  file.close()
  return new(dict)

func apply_part(args):
  var map = args[0]
  var grid = args[1]
  var j0 = args[2]
  var i0 = args[3]
  var w = args[4]
  var h = args[5]
  printt("thread", args[2], args[3], args[2] + args[4] - 1, args[3] + args[5] - 1)
  for i in range(i0, i0+h):
    for j in range(j0, j0+w):
      #sem_.wait()
      grid.set_tile(i, j, map[i][j])
      #sem_.post()
      for key in rules_:
        var patterns = rules_[key].patterns
        var value = rules_[key].value
        for pattern in patterns:
          var change = true
          for d in WINDOW:
            var tile = map[i+d.y][j+d.x]
            var pat = pattern[d.y+1][d.x+1]
            if not ( pat == ANY or tile == pat or (pat == ANY_BUT_WALL and tile != WALL) ):
              change = false
              break
          if change:
            grid.set_tile(i, j, value)
            break

# override
func apply(map, w, h):
  var map_grid = MapGrid.new(w, h, EMPTY)
  var threads = range(THREAD_NUM)
  for i in range(THREAD_NUM):
    threads[i] = Thread.new()
  sem_ = Semaphore.new()
  sem_.post()
  for i in range(THREAD_NUM-1):
    threads[i].start(self, "apply_part", [map, map_grid, 1, 1+i*h/THREAD_NUM, w-2, h/THREAD_NUM])
  threads[THREAD_NUM-1].start(self, "apply_part", [map, map_grid, 1, 1+(THREAD_NUM-1)*h/THREAD_NUM, w-2, h/THREAD_NUM-2])
  for i in range(THREAD_NUM):
    threads[i].wait_to_finish()
  sem_ = null
  return map_grid
