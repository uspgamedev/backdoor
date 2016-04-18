
extends TileMap

const block = [
	Vector2(1,0),
	Vector2(0,1),
	Vector2(1,1)
]

const Action   = preload("res://model/action.gd")
const Actor    = preload("res://model/actor.gd")
const Body     = preload("res://model/body.gd")
const BodyView = preload("res://scenes/bodyview.gd")

onready var preload_bodies = [
	[Body.new("hero", Vector2(22,8), 10), get_node("/root/player")],
	[Body.new("slime", Vector2(22,6), 10), Actor.new()]
]

var bodies
var body_views
var actor_bodies
onready var player = get_node("/root/player")

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	bodies = []
	body_views = []
	actor_bodies = {}
	for entry in preload_bodies:
		add_body(entry[0])
		add_actor(entry[0],entry[1])
	manage_actors()

func add_body(body):
	var bodyview = BodyView.create(body)
	bodies.append(body)
	body_views.append(bodyview)
	add_child(bodyview)

func add_actor(body, actor):
	get_node("../actors").add_child(actor)
	actor_bodies[actor] = body
	var module = preload("res://model/ai/wander.gd").new()
	actor.add_child(module)

func _fixed_process(delta):
	for bodyview in body_views:
		bodyview.set_pos(map_to_world(bodyview.body.pos) + Vector2(0, 16 - 1))
	for actor in actor_bodies:
		if actor != player and !actor.has_action() and actor.is_ready():
			actor.pick_ai_module().think()

func move_actor(actor, new_pos):
	move_body(actor_bodies[actor], new_pos)

func is_empty_space(pos):
	return get_cell(pos.x, pos.y) == -1

func move_body(body, new_pos):
	if body == actor_bodies[player]:
		for diff in block:
			var pos = body.pos + diff
			var cell = get_cell(pos.x, pos.y)
			if cell > 0 && cell % 2 == 0:
				set_cell(pos.x, pos.y, cell - 1)
	body.pos = new_pos
	if body == actor_bodies[player]:
		for diff in block:
			var pos = body.pos + diff
			var cell = get_cell(pos.x, pos.y)
			if cell % 2 == 1:
				set_cell(pos.x, pos.y, cell + 1)

func get_body_at (pos):
	for body in bodies:
		if body.pos == pos:
			return body
	return null

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().finish()
	if player.is_ready():
		var move = Vector2(0,0)
		if event.is_action_pressed("ui_down"):
			move.y += 1
		elif event.is_action_pressed("ui_up"):
			move.y -= 1
		elif event.is_action_pressed("ui_right"):
			move.x += 1
		elif event.is_action_pressed("ui_left"):
			move.x -= 1
		if event.is_action_pressed("ui_idle"):
			player.add_action(Action.Idle.new())
		elif move.length_squared() > 0:
			var target_pos = bodies[0].pos + move
			var body = get_body_at(target_pos)
			if body != null:
				player.add_action(Action.MeleeAttack.new(body))
			else:
				player.add_action(Action.Move.new(target_pos))

func manage_actors():
	while true:
		for actor in actor_bodies:
			actor.step_time()
			if actor.is_ready():
				if !actor.has_action():
					yield(actor, "has_action")
				actor.use_action()
		yield(get_tree(), "fixed_frame" )

