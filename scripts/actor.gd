
extends Sprite

var cooldown
var action
export var speed = 10

const costs = {
	"idle": 100,
	"move": 100
}

signal has_action
signal spent_action

func _ready():
	cooldown = 0

func step_time():
	cooldown = max(0, cooldown - 1)

func is_ready():
	return cooldown == 0

func has_action():
	return action != null

func get_action():
	var the_action = action
	cooldown += costs[action.type]/speed
	action = null
	emit_signal("spent_action")
	return the_action
	
func add_action(the_action):
	if !has_action():
		action = the_action
		emit_signal("has_action")
