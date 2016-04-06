
extends Sprite

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

const DRAW_TIME = 40
const MAX_HAND = 5

signal has_action
signal spent_action
signal draw_card(card)

func _ready():
	cooldown = 100/speed
	draw_cooldown = DRAW_TIME
	hand = []
	deck = []
	deck.append(Card.new("Black Lotus"))
	deck.append(Card.new("Dr. Boom"))
	deck.append(Card.new("Exodia"))
	deck.append(Card.new("Exodia"))
	deck.append(Card.new("Exodia"))
	deck.append(Card.new("Exodia"))
	deck.append(Card.new("Exodia"))
	deck.append(Card.new("Exodia"))
	deck.append(Card.new("Exodia"))

func get_body_pos():
	return get_parent().actors[self].pos

func step_time():
	cooldown = max(0, cooldown - 1)
	draw_cooldown = max(0, draw_cooldown - 1)

func check_draw():
	if draw_cooldown == 0 and hand.size() < MAX_HAND and deck.size() > 0:
		hand.append(deck[0])
		deck.remove(0)
		draw_cooldown = DRAW_TIME
		emit_signal("draw_card", hand[hand.size() - 1])

func is_ready():
	return cooldown == 0

func has_action():
	return action != null

func add_action(the_action):
	if !has_action() and the_action.can_be_used(self):
		action = the_action
		emit_signal("has_action")

func use_action():
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
