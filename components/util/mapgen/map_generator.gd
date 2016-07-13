
extends Node

const MapGrid = preload("res://components/util/mapgen/map_grid.gd")
const RandomStep = preload("res://components/util/mapgen/steps/random_step.gd")
const RoomStep = preload("res://components/util/mapgen/steps/room_step.gd")
const PatternStep = preload("res://components/util/mapgen/steps/pattern_step.gd")
const BorderStep = preload("res://components/util/mapgen/steps/border_step.gd")

var RANDOM_STEP = RandomStep.new()
var ROOM_STEP = RoomStep.new()
var GROW_STEP = PatternStep.load_from_file("growing_patterns")
var CLEAN_STEP = PatternStep.load_from_file("cleaning_patterns")
var BORDER_STEP = BorderStep.new()

var PIPELINE = [
  ROOM_STEP,
  #RANDOM_STEP, RANDOM_STEP, RANDOM_STEP,
  #GROW_STEP, GROW_STEP, GROW_STEP,
  CLEAN_STEP, CLEAN_STEP, CLEAN_STEP,
  BORDER_STEP
]

func _ready():
    pass

func generate_map(id,w,h):
  var map = MapGrid.new(w,h)
  for step in PIPELINE:
    map = map.apply_step(step)
  return map.export_scene(id)
