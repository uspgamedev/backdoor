
extends Node2D

const MapScene = preload("res://scenes/map.xscn")

const Body = preload("res://model/body.gd")
const BodyView = preload("res://scenes/bodyview.gd")

const block = [
	Vector2(1,0),
	Vector2(0,1),
	Vector2(1,1)
]

var id
var width
var height
var bodies
var actor_bodies
onready var walls = get_node("walls")

static func create(id, width, height):
	var map_node = MapScene.instance()
	map_node.get_node("floors").clear()
	map_node.get_node("walls").clear()
	map_node.width = width
	map_node.height = height
	map_node.id = id
	map_node.hide()
	return map_node

func _init():
	bodies = []
	actor_bodies = {}
	print("map created")

func _ready():
	print("map ready")
	pass
	
func is_empty_space(pos):
	return walls.get_cell(pos.x, pos.y) == -1

func find_free_body_id():
	var id = 1
	while Body.find(bodies, id):
		id += 1
	return id

func add_body(body):
	var bodyview = BodyView.create(body)
	bodies.append(body)
	get_node("walls").add_child(bodyview)

func remove_body(body):
	bodies.erase(body)
	get_node("walls").remove_child(find_body_view(body))

func find_body_view(body):
	for bodyview in get_node("walls").get_children():
		if bodyview.body == body:
			return bodyview

func add_actor(body, actor):
	get_node("actors").add_child(actor)
	actor_bodies[actor] = body
	#var module = preload("res://model/ai/wander.gd").new()
	#actor.add_child(module)

func remove_actor(actor):
	if actor_bodies[actor] != null:
		remove_body(actor_bodies[actor])
		actor_bodies.erase(actor)
	get_node("actors").remove_child(actor)

func attach_camera(actor):
	var bodyview = find_body_view(actor_bodies[actor])
	var camera = Camera2D.new()
	camera.make_current()
	camera.set_enable_follow_smoothing(true)
	camera.set_follow_smoothing(5)
	bodyview.add_child(camera)

func move_actor(actor, new_pos):
	move_body(actor_bodies[actor], new_pos)

func move_body(body, new_pos):
	body.pos = new_pos

func get_actor_body(actor):
	return actor_bodies[actor]

func get_body_actor(body):
	for actor in actor_bodies:
		if actor_bodies[actor] == body:
			return actor

func get_body_at(pos):
	for body in bodies:
		if body.pos == pos:
			return body
	return null

func check_dead_bodies():
	for body in bodies:
		if body.is_dead():
			remove_actor(get_body_actor(body))

func _fixed_process(delta):
	var player_body = get_actor_body(get_parent().player)
	for i in range(5):
		for j in range(5):
			var pos = player_body.pos + Vector2(-2 + i,-2 + j)
			var cell = walls.get_cell(pos.x, pos.y)
			if cell > 0 && cell % 2 == 0:
				walls.set_cell(pos.x, pos.y, cell - 1)
	for diff in block:
		var pos = player_body.pos + diff
		var cell = walls.get_cell(pos.x, pos.y)
		if cell % 2 == 1:
			walls.set_cell(pos.x, pos.y, cell + 1)

