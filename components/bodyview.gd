
extends Node2D

const BodyViewScene = preload("res://components/bodyview.tscn")
const IO = preload("res://components/util/io.gd")

var body

onready var sprite = get_node("Sprite")
onready var animation = get_node("Sprite/Animation")
onready var lifebar = get_node("Sprite/LifeBar")
onready var hl_indicator = get_node("Highlight")
var metadata = {}

export(bool) var highlight = false

static func create(body):
	var bodyview = BodyViewScene.instance()
	bodyview.body = body
	return bodyview

func _ready():
	metadata.parse_json(IO.get_file_as_text("res://assets/bodies/" + body.type + "/meta.json"))
	sprite.set_texture(load("res://assets/bodies/" + body.type + "/idle.png"))
	animation.play("idle")
	init_metadata()
	set_process(true)

func init_metadata():
  # this function gets the bodyview's metadata in json and applies it to the bodyview's nodes.
  if metadata.has("height"):
    if metadata.height == 0:
      get_node("Sprite/LifeBar").set_pos(Vector2(-16, -48))
    elif metadata.height == 1:
      get_node("Sprite/LifeBar").set_pos(Vector2(-16, -64))
    elif metadata.height == 2:
      get_node("Sprite/LifeBar").set_pos(Vector2(-16, -80))
  if metadata.has("offset"):
    get_node("Sprite").set_offset(Vector2(metadata.offset.x, metadata.offset.y))

func highlight():
	highlight = true
	update_hl()

func unhighlight():
	highlight = false
	update_hl()

func set_hl_color(color):
	get_node("Highlight").set_modulate(color)

func update_hl():
	if highlight:
		get_node("Highlight").show()
	else:
		get_node("Highlight").hide()

func _process(delta):
	set_pos(get_parent().map_to_world(body.pos) + Vector2(0, 16 - 1))
	lifebar.set_value(body.get_hp_percent())
