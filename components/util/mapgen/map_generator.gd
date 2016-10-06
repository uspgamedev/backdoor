
extends Node

const MapGrid = preload("res://components/util/mapgen/map_grid.gd")
const Step = preload("res://components/util/mapgen/step.gd")
const RandomStep = preload("res://components/util/mapgen/steps/add_random_tiles.gd")
const RoomStep = preload("res://components/util/mapgen/steps/carve_rooms.gd")
const PatternStep = preload("res://components/util/mapgen/steps/pattern_filter.gd")
const MarginStep = preload("res://components/util/mapgen/steps/add_margin.gd")

var ROOM_STEP = RoomStep.new()
var GROW_STEP = PatternStep.load_from_file("growing")
var CLEAN_STEP = PatternStep.load_from_file("cleaning")
var BORDER_STEP = PatternStep.load_from_file("border")
var MARGIN_STEP = MarginStep.new()
var DIRT_STEP = RandomStep.new(Step.EMPTY, Step.FLOOR_DIRT, 0.01)

var PIPELINE = [
  ROOM_STEP,
  #RANDOM_STEP, RANDOM_STEP, RANDOM_STEP,
  #GROW_STEP, GROW_STEP, GROW_STEP,
  MARGIN_STEP,
  CLEAN_STEP, #CLEAN_STEP, CLEAN_STEP,
  BORDER_STEP,
  DIRT_STEP,
]

func _ready():
    pass

func generate_map(w,h,assembler):
  var map = MapGrid.new(w,h, Step.WALL)
  var i = 0
  for step in PIPELINE:
    i += 1
    printt("step", i)
    map = map.apply_step(step)
  return map.export_scene(assembler)
