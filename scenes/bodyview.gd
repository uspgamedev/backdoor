
extends Node2D

const BodyViewScene = preload("res://scenes/bodyview.xscn")

var body

onready var lifebar = get_node("LifeBar")

static func create(body):
	var bodyview = BodyViewScene.instance()
	bodyview.body = body
	return bodyview

func _ready():
	set_process(true)

func _process(delta):
	set_pos(get_parent().map_to_world(body.pos) + Vector2(0, 16 - 1))
	lifebar.set_value(body.get_hp_percent())
