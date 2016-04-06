
extends TileMap

var bodies
const block = [
	Vector2(1,0),
	Vector2(0,1),
	Vector2(1,1)
]

var Action = preload("res://model/action.gd")
var actors
var player

class Body:
	var pos
	var node

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	bodies = []
	actors = {}
	var count = 0
	for actor in get_children():
		var body = Body.new()
		body.pos = Vector2(5,3 + count)
		body.node = actor
		bodies.append(body)
		actors[actor] = body
		count += 1
	player = get_node("Hero")
	manage_actors()

func _fixed_process(delta):
	for body in bodies:
		body.node.set_pos(map_to_world(body.pos) + Vector2(0, 32 - 1))
	for actor in actors:
		if actor != player and !actor.has_action() and actor.is_ready():
			actor.pick_ai_module().think()

func move_actor(actor, new_pos):
	move_body(actors[actor], new_pos)

func is_empty_space(pos):
	return get_cell(pos.x, pos.y) == -1

func move_body(body, new_pos):
	if body == actors[player]:
		for diff in block:
			var pos = body.pos + diff
			var cell = get_cell(pos.x, pos.y)
			if cell > 0 && cell % 2 == 0:
				set_cell(pos.x, pos.y, cell - 1)
	body.pos = new_pos
	if body == actors[player]:
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
		for actor in actors:
			actor.step_time()
			actor.check_draw()
			if actor.is_ready():
				if !actor.has_action():
					yield(actor, "has_action")
				actor.use_action()
		yield(get_tree(), "fixed_frame" )

