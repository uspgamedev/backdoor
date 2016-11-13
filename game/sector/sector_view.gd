
extends Node2D

const ViewScene     = preload("res://game/sector/sector_view.tscn")
const Parallax      = preload("res://components/util/parallax_background.tscn")

const Tiles         = preload("res://game/sector/tiles.gd")
const Actor         = preload("res://model/actor.gd")
const Body          = preload("res://model/body.gd")
const BodyView      = preload("res://components/bodyview.gd")
const Identifiable  = preload("res://model/identifiable.gd")

var current_sector

onready var floors = get_node("floors")
onready var walls = get_node("walls")

static func create(id, width, height):
  var map_node = ViewScene.instance()
  map_node.get_node("floors").clear()
  map_node.get_node("walls").clear()
  map_node.width = int(width)
  map_node.height = int(height)
  map_node.id = id
  map_node.hide()
  return map_node

func get_current_sector():
  return current_sector

func load_sector(sector):
  self.current_sector = sector
  self.floors.clear()
  self.walls.clear()
  for body_view in self.walls.get_children():
    body_view.queue_free()
  for tile in sector.get_tiles():
    var value = sector.get_tile_v(tile)
    if Tiles.is_floor(value):
      self.floors.set_cell(tile.x, tile.y, value)
    if Tiles.is_wall(value):
      self.walls.set_cell(tile.x, tile.y, value)
  for body in sector.get_bodies():
    add_body_view(body)

func add_body_view(body):
  var bodyview = BodyView.create(body)
  if body.type != "hero":
    bodyview.set_hl_color(Color(1.0, .1, .2, .3))
  else:
    bodyview.highlight()
  get_node("walls").add_child(bodyview)
  body.connect("moved", bodyview, "set_dir")

func attach_camera(actor):
  var bodyview = find_body_view(current_sector.get_actor_body(actor))
  var camera = Camera2D.new()
  camera.make_current()
  camera.set_enable_follow_smoothing(true)
  camera.set_follow_smoothing(5)
  bodyview.add_child(camera)
  add_bg()

func add_bg():
  var parallax_bg = Parallax.instance()
  get_node("background").add_child(parallax_bg)

func find_body_view(body):
  for bodyview in get_node("walls").get_children():
    if bodyview.body == body:
      return bodyview
  assert(false)
