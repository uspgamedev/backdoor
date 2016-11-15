
const MapGrid = preload("res://game/procedural/map/grid.gd")
const Step = preload("res://game/procedural/map/step.gd")
const RandomStep = preload("res://game/procedural/map/steps/add_random_tiles.gd")
const RoomStep = preload("res://game/procedural/map/steps/carve_rooms.gd")
const PatternStep = preload("res://game/procedural/map/steps/pattern_filter.gd")
const MarginStep = preload("res://game/procedural/map/steps/add_margin.gd")
const ExpandStep = preload("res://game/procedural/map/steps/grow_smooth.gd")

var ROOM_STEP = RoomStep.new()
var GROW_STEP = PatternStep.load_from_file("growing")
var CLEAN_STEP = PatternStep.load_from_file("cleaning")
var MARGIN_STEP = MarginStep.new()
var DIRT_STEP = RandomStep.new(Step.EMPTY, Step.FLOOR_DIRT, 0.01)
var EXPAND_DIRT_STEP1 = ExpandStep.new(Step.EMPTY, Step.FLOOR_DIRT, 2, 8, 5)
var EXPAND_DIRT_STEP2 = ExpandStep.new(Step.EMPTY, Step.FLOOR_DIRT, 2, 8, 3)

var PIPELINE = [
  ROOM_STEP,
  #RANDOM_STEP, RANDOM_STEP, RANDOM_STEP,
  #GROW_STEP, GROW_STEP, GROW_STEP,
  MARGIN_STEP,
  CLEAN_STEP, #CLEAN_STEP, CLEAN_STEP,
  DIRT_STEP,
  EXPAND_DIRT_STEP1, EXPAND_DIRT_STEP2,
]

func generate_map(w,h,assembler):
  var map = MapGrid.new(w,h, Step.WALL)
  var i = 0
  for step in PIPELINE:
    i += 1
    printt("step", i)
    map = map.apply_step(step)
  return map.export_scene(assembler)
