
extends Node2D

const MapScene = preload("res://scenes/map.xscn")

const Actor        = preload("res://model/actor.gd")
const Body         = preload("res://model/body.gd")
const BodyView     = preload("res://components/bodyview.gd")
const Identifiable = preload("res://model/identifiable.gd")

const block = [
	Vector2(1,0),
	Vector2(0,1),
	Vector2(1,1),
	Vector2(2,0),
	Vector2(0,2),
	Vector2(2,1),
	Vector2(1,2),
	Vector2(2,2)
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
	assert(false)

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
	var bodyview = find_body_view(get_actor_body(actor))
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
	assert(actor_bodies.has(actor))
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
			var actor = get_body_actor(body)
			if actor == get_parent().player:
				get_node("/root/captains_log/scene_manager").call_deferred("destroy_route")
			else:
				remove_actor(actor)

func _fixed_process(delta):
	var player_body = get_actor_body(get_parent().player)
	for i in range(7):
		for j in range(7):
			var pos = player_body.pos + Vector2(-2 + i,-2 + j)
			var cell = walls.get_cell(pos.x, pos.y)
			if cell > 0 && cell % 2 == 0:
				walls.set_cell(pos.x, pos.y, cell - 1)
	for diff in block:
		var pos = player_body.pos + diff
		var cell = walls.get_cell(pos.x, pos.y)
		if cell % 2 == 1:
			walls.set_cell(pos.x, pos.y, cell + 1)

func serialize():
	# Store sector general data
	var sector_data = {}
	sector_data["id"] = id
	sector_data["width"] = width
	sector_data["height"] = height
	# Store floor tiles
	var floor_map = []
	for i in range(height):
		for j in range(width):
			floor_map.append(-1)
	var floors = get_node("floors")
	for tile_pos in floors.get_used_cells():
		floor_map[tile_pos.x*width + tile_pos.y] = floors.get_cellv(tile_pos)
	sector_data["floors"] = floor_map
	# Store wall tiles
	var wall_map = []
	for i in range(height):
		for j in range(width):
			wall_map.append(-1)
	var walls = get_node("walls")
	for tile_pos in walls.get_used_cells():
		wall_map[tile_pos.x*width + tile_pos.y] = walls.get_cellv(tile_pos)
	sector_data["walls"] = wall_map
	# Store bodies
	var bodies = []
	for body in self.bodies:
		bodies.append(body.serialize())
	sector_data["bodies"] = bodies
	# Store actors
	var actors = []
	for actor in actor_bodies:
		actors.append(actor.serialize())
	sector_data["actors"] = actors
	return sector_data

static func unserialize(data, root):
	# Parse sector
	var map = create(data["id"], data["width"], data["height"])
	# General sector info
	# Parse sector floor
	var floors = map.get_node("floors")
	floors.clear()
	var floor_data = data["floors"]
	for j in range(floor_data.size()):
		floors.set_cell(j / int(map.width), j % int(map.width), floor_data[j])
	# Parse sector walls
	var walls = map.get_node("walls")
	walls.clear()
	var wall_data = data["walls"]
	for j in range(wall_data.size()):
		walls.set_cell(j / int(map.width), j % int(map.width), wall_data[j])
	# Parse bodies
	var bodies = data["bodies"]
	for body_data in bodies:
		map.add_body(Body.unserialize(body_data))
	# Parse actors
	var actors = data["actors"]
	for actor_data in actors:
		var actor = Actor.unserialize(actor_data, root)
		map.add_actor(Identifiable.find(map.bodies, actor_data["body_id"]), actor)
	return map
