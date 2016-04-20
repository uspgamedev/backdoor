
extends Node2D

const block = [
	Vector2(1,0),
	Vector2(0,1),
	Vector2(1,1)
]

onready var walls = get_node("walls")

func _ready():
	set_fixed_process(true)
	
func is_empty_space(pos):
	return walls.get_cell(pos.x, pos.y) == -1

func _fixed_process(delta):
	var player_body = get_parent().get_actor_body(get_parent().player)
	for i in range(5):
		for j in range(5):
			var pos = player_body.pos + Vector2(i,j)
			var cell = walls.get_cell(pos.x, pos.y)
			if cell > 0 && cell % 2 == 0:
				walls.set_cell(pos.x, pos.y, cell - 1)
	for diff in block:
		var pos = player_body.pos + diff
		var cell = walls.get_cell(pos.x, pos.y)
		if cell % 2 == 1:
			walls.set_cell(pos.x, pos.y, cell + 1)

