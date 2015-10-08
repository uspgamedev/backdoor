
extends Sprite

var cooldown
var action

const costs = {
	"move": 10
}

signal has_action

func _ready():
	cooldown = 0

func step_time():
	cooldown = max(0, cooldown - 1)
	print(cooldown)

func is_ready():
	return cooldown == 0

func has_action():
	return action != null

func get_action():
	var the_action = action
	action = null
	return the_action
	
func add_action(the_action):
	if is_ready():
		action = the_action
		cooldown += costs[action.type]
		emit_signal("has_action")
