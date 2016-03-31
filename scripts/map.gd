
extends TileMap

var bodies
const block = [
	Vector2(1,0),
	Vector2(0,1),
	Vector2(1,1)
]

var Action = preload("action.gd")
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
		if actor != player and !actor.has_action():
			actor.add_action(Action.Move.new(actors[actor].pos + Vector2(0,-1)))

func move_actor(actor, new_pos):
	move_body(actors[actor], new_pos)

func move_body(body, new_pos):
	if get_cell(new_pos.x, new_pos.y) == 0:
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

func _input(event):
	var move = Vector2(0,0)
	if event.is_action_pressed("ui_down"):
		move.y += 1
	elif event.is_action_pressed("ui_up"):
		move.y -= 1
	elif event.is_action_pressed("ui_right"):
		move.x += 1
	elif event.is_action_pressed("ui_left"):
		move.x -= 1
	if move.length_squared() > 0:
		var move_action = Action.Move.new(bodies[0].pos + move)
		player.add_action(move_action)

func manage_actors():
	while true:
		for actor in actors:
			actor.step_time()
			actor.check_draw()
			if actor.is_ready():
				if !actor.has_action():
					yield(actor, "has_action")
				var action = actor.get_action()
				if action.can_be_used(actor):
					action.use(actor)
				#if action.type == "move":
				#	move_body(actors[actor], action.arg)
		yield(get_tree(), "fixed_frame" )

