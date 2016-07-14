
extends Node

const MapGrid = preload("res://components/util/mapgen/map_grid.gd")
const Step = preload("res://components/util/mapgen/step.gd")
const RandomStep = preload("res://components/util/mapgen/steps/add_random_wall.gd")
const RoomStep = preload("res://components/util/mapgen/steps/carve_rooms.gd")
const PatternStep = preload("res://components/util/mapgen/steps/pattern_filter.gd")

var RANDOM_STEP = RandomStep.new()
var ROOM_STEP = RoomStep.new()
var GROW_STEP = PatternStep.load_from_file("growing")
var CLEAN_STEP = PatternStep.load_from_file("cleaning")
var BORDER_STEP = PatternStep.load_from_file("border")

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
  var map = MapGrid.new(w,h, Step.WALL)
  for step in PIPELINE:
    map = map.apply_step(step)
  return map.export_scene(id)
