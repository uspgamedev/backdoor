
extends TileMap

var bodies
const block = [
	Vector2(1,0),
	Vector2(0,1),
	Vector2(1,1)
]

var actors
var player

class Body:
	var pos
	var node
	
class Action:
	var type
	var arg
	func _init(the_type, the_arg):
		type = the_type
		arg = the_arg

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
			actor.add_action(Action.new("move", actors[actor].pos + Vector2(0,-1)))

func move_body(body, new_pos):
	if get_cell(new_pos.x, new_pos.y) == 0:
		body.pos = new_pos
		for tile in get_used_cells():	
			if get_cell(tile.x, tile.y) == 2:
				set_cell(tile.x, tile.y, 1)
		for diff in block:
			var pos = body.pos + diff
			if get_cell(pos.x, pos.y) == 1:
				set_cell(pos.x, pos.y, 2)

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
		var move_action = Action.new("move", bodies[0].pos + move)
		player.add_action(move_action)

func manage_actors():
	while true:
		for actor in actors:
			actor.step_time()
			if actor.is_ready():
				if !actor.has_action():
					yield(actor, "has_action")
				var action = actor.get_action()
				if action.type == "move":
					move_body(actors[actor], action.arg)
		yield(get_tree(), "fixed_frame" )

