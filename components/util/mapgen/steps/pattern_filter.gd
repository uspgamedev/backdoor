
extends "res://components/util/mapgen/step.gd"

var rules_

func _init(dict):
  rules_ = dict

static func load_from_file(pattern_name):
  var dict = {}
  var file = File.new()
  var text = ""
  file.open("res://components/util/mapgen/patterns/" + pattern_name + ".json", File.READ)
  text = file.get_as_text()
  dict.parse_json(text)
  file.close()
  return new(dict)

# override
func apply(map, w, h):
  var map_grid = MapGrid.new(w, h, EMPTY)
  for i in range(1, w - 1):
    for j in range(1, h - 1):
      map_grid.set_tile(i, j, map[i][j])
      for key in rules_:
        var rule = rules_[key]
        for pattern in rule.patterns:
          var change = true
          for di in range(-1,2):
            for dj in range(-1,2):
              if not ( pattern[di+1][dj+1] == ANY or map[i+di][j+dj] == pattern[di+1][dj+1] or (pattern[di+1][dj+1] == ANY_BUT_WALL and map[i+di][j+dj] != WALL) ):
                change = false
          if change:
            map_grid.set_tile(i, j, rule.value)
            break
  return map_grid
