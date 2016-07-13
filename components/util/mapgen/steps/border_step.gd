
extends "res://components/util/mapgen/step.gd"

const PatternStep = preload("res://components/util/mapgen/steps/pattern_step.gd")

var substeps_

func _init():
  var dict = {}
  var file = File.new()
  var text = ""
  file.open("res://components/util/mapgen/patterns/border_patterns.json", File.READ)
  text = file.get_as_text()
  dict.parse_json(text)
  file.close()
  substeps_ = []
  for rule in dict:
    substeps_.push_back(PatternStep.new(dict[rule].patterns, dict[rule].value))

# override
func apply(map, w, h):
  var map_grid = MapGrid.clone(map, w, h)
  for step in substeps_:
    map_grid = map_grid.apply_step(step)
  return map_grid
