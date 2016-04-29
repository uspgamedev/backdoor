
extends Node

class Card:
	var name
	func _init(the_name):
		name = the_name

var cooldown
var draw_cooldown
var action

var hand
var deck

export(int) var speed = 10
export(int) var draw_rate = 5

const DRAW_TIME = 40
const MAX_HAND = 5

signal has_action
signal spent_action
signal draw_card(card)

func _init():
	hand = []
	deck = []

func _ready():
	cooldown = 100/speed
	draw_cooldown = DRAW_TIME

func get_body():
	return get_node("/root/sector/map").get_actor_body(self)

func get_body_pos():
	return get_body().pos

func can_draw():
	return hand.size() < MAX_HAND and deck.size() > 0

func step_time():
	cooldown = max(0, cooldown - 1)
	while draw_cooldown <= 0 and can_draw():
		hand.append(deck[0])
		deck.remove(0)
		draw_cooldown += DRAW_TIME
		emit_signal("draw_card", hand[hand.size() - 1])
	if can_draw():
		draw_cooldown -= draw_rate

func is_ready():
	return cooldown == 0

func has_action():
	return action != null

func add_action(the_action):
	if !has_action() and the_action.can_be_used(self):
		action = the_action
		print(get_name(), ": added action ", action.get_type())
		emit_signal("has_action")

func use_action():
	print(get_name(), ": used action ", action.get_type())
	cooldown += action.get_cost(self)/speed
	action.use(self)
	action = null
	emit_signal("spent_action")

func pick_ai_module():
	var total = 0
	for module in get_children():
		total += module.chance
	var roll = total*randf()
	var acc = 0
	for module in get_children():
		acc += module.chance
		if acc >= roll:
			return module
	return get_child(0)
