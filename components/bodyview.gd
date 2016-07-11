
extends Node2D

const BodyViewScene = preload("res://components/bodyview.tscn")

var body

onready var sprite = get_node("Sprite")
onready var lifebar = get_node("Sprite/LifeBar")
onready var hl_indicator = get_node("Highlight")

export(bool) var highlight = false

static func create(body):
	var bodyview = BodyViewScene.instance()
	bodyview.body = body
	return bodyview

func _ready():
	sprite.set_texture(load("res://assets/bodies/" + body.type + "/idle.tex"))
	set_process(true)

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
