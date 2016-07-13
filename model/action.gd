
extends Object

class BaseAction:
	var type_
	func _init(type):
		type_ = type
	func can_be_used(actor):
		return false
	func get_cost(actor):
		return 0
	func use(actor):
		pass

class Idle:
	extends BaseAction
	func _init().("idle"):
		pass
	func get_cost(actor):
		return 100
	func can_be_used(actor):
		return true

class Move:
	extends BaseAction
	var target_
	func _init(target).("move"):
		target_ = target
	func get_map(actor):
		return actor.get_node("/root/sector/map")
	func can_be_used(actor):
		return get_map(actor).is_empty_space(target_) && get_map(actor).get_body_at(target_) == null
	func get_cost(actor):
		return 50
	func use(actor):
		get_map(actor).move_actor(actor, target_)
		pass

class MeleeAttack:
	extends BaseAction
	var body_
	func _init(body).("melee_attack"):
		body_ = body
	func can_be_used(actor):
		return true
	func get_cost(actor):
		return 100
	func use(actor):
		body_.take_damage(actor.attributes.melee_attack)

class ChangeSector:
	extends BaseAction
	var target_
	func _init(target).("change_sector"):
		target_ = target
	func can_be_used(actor):
		return true
	func get_cost(actor):
		return 50
	func use(actor):
		actor.get_node("/root/sector").set_next_sector(target_)

class EvokeCard:
	extends BaseAction
	var card_
	var options_
	func _init(card).("use_card"):
		card_ = card
		options_ = []
	func add_option(option):
		options_.append(option)
	func get_cost(actor):
		return card_.card_ref.get_time_cost()
	func can_be_used(actor):
		return (card_.card_ref.can_be_evoked(actor))
	func use(actor):
		actor.consume_card(card_)
		card_.card_ref.evoke(actor,options_)
