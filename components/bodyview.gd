
extends Node2D

const BodyViewScene = preload("res://components/bodyview.tscn")
const IO = preload("res://components/util/io.gd")

const LEFT = false
const RIGHT = true

const LIFEBAR_HEIGHT_SMALL  = Vector2(-16, -48)
const LIFEBAR_HEIGHT_MEDIUM = Vector2(-16, -64)
const LIFEBAR_HEIGHT_TALL	 = Vector2(-16, -80)

var body

onready var sprite = get_node("Sprite")
onready var animation = get_node("Sprite/Animation")
onready var lifebar = get_node("Sprite/LifeBar")
onready var hl_indicator = get_node("Highlight")
var dir = LEFT
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
      get_node("Sprite/LifeBar").set_pos(LIFEBAR_HEIGHT_SMALL)
    elif metadata.height == 1:
      get_node("Sprite/LifeBar").set_pos(LIFEBAR_HEIGHT_MEDIUM)
    elif metadata.height == 2:
      get_node("Sprite/LifeBar").set_pos(LIFEBAR_HEIGHT_TALL)
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

func set_dir(current_pos, new_pos):
	var dir_vec = new_pos - current_pos
	if dir_vec.x - dir_vec.y < 0:
		turn_left()
	else:
		turn_right()

func turn_right():
	dir = RIGHT

func turn_left():
	dir = LEFT

func _process(delta):
	set_pos(get_parent().map_to_world(body.pos) + Vector2(0, 16 - 1))
	lifebar.set_value(body.get_hp_percent())
	sprite.set_flip_h(dir)
