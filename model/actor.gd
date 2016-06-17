
extends Node

class Card:
	var card_ref
	func _init(ref):
		card_ref = ref
	func get_name():
		return card_ref.get_name()
	func get_description():
		return card_ref.get_description()
	func get_ref():
		return card_ref

var cooldown
var draw_cooldown
var action
var char_name

var hand
var deck

var weapon
var armory
var accessory

export(int) var speed = 10
export(int) var draw_rate = 5

const DRAW_TIME = 120
const MAX_HAND = 5

signal has_action
signal spent_action
signal draw_card(card)
signal consumed_card(card)
signal update_deck

func _init(name):
	hand = []
	deck = []
	char_name = name

func _ready():
	cooldown = 100/speed
	draw_cooldown = DRAW_TIME

func get_body():
	return get_node("/root/sector/map").get_actor_body(self)

func get_body_pos():
	return get_body().pos

func can_draw():
	return hand.size() < MAX_HAND and deck.size() > 0

func consume_card(card):
	hand.erase(card)
	emit_signal("consumed_card", card)

func step_time():
	cooldown = max(0, cooldown - 1)
	while draw_cooldown <= 0 and can_draw():
		hand.append(deck[0])
		deck.remove(0)
		draw_cooldown += DRAW_TIME
		emit_signal("draw_card", hand[hand.size() - 1])
		emit_signal("update_deck")
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

func serialize():
	var sector = get_parent().get_parent()
	var actor_data = {}
	actor_data["name"] = char_name
	actor_data["cooldown"] = cooldown
	actor_data["drawcooldown"] = draw_cooldown
	var hand_data = []
	var cards_db = get_node("/root/captains_log/cards")
	for card in hand:
		hand_data.append(cards_db.get_card_id(card.get_ref()))
	actor_data["hand"] = hand_data
	var deck_data = []
	for card in deck:
		deck_data.append(cards_db.get_card_id(card.get_ref()))
	actor_data["deck"] = deck_data
	actor_data["body_id"] = sector.get_actor_body(self).get_id()
	var ai_modules_data = []
	for module in get_children():
		var module_data = {}
		module_data["name"] = module.get_name()
		module_data["chance"] = module.chance
		ai_modules_data.append(module_data)
	actor_data["ai_modules"] = ai_modules_data
	return actor_data

static func unserialize(data, root):
	var actor = new(data["name"])
	actor.cooldown = data["cooldown"]
	actor.draw_cooldown = data["drawcooldown"]
	var cards_db = root.get_node("captains_log/cards")
	var hand = data["hand"]
	for card in hand:
		actor.hand.append(Card.new(cards_db.get_child(card)))
	var deck = data["deck"]
	for card in deck:
		actor.deck.append(Card.new(cards_db.get_child(card)))
	var ai_modules = data["ai_modules"]
	for module in ai_modules:
		var ai = Node.new()
		ai.set_script(load("res://model/ai/" + module["name"] + ".gd"))
		ai.set_name(module["name"])
		ai.chance = module["chance"]
		actor.add_child(ai)
	return actor
