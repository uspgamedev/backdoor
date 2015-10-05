
extends TileMap

var bodies
const block = [
	Vector2(1,0),
	Vector2(0,1),
	Vector2(1,1)
]

class Body:
	var pos
	var node

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	bodies = []
	var hero = Body.new()
	hero.pos = Vector2(5,5)
	hero.node = get_node("Hero")
	bodies.append(hero)

func _fixed_process(delta):
	for body in bodies:
		body.node.set_pos(map_to_world(body.pos) + Vector2(0, 32 - 1))

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
	var new_pos = bodies[0].pos + move
	if get_cell(new_pos.x, new_pos.y) == 0:
		bodies[0].pos = new_pos
		for tile in get_used_cells():	
			if get_cell(tile.x, tile.y) == 2:
				set_cell(tile.x, tile.y, 1)
		for diff in block:
			var pos = bodies[0].pos + diff
			if get_cell(pos.x, pos.y) == 1:
				set_cell(pos.x, pos.y, 2)
