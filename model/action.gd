
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
	func can_be_used(actor):
		var map = actor.get_parent()
		var result = map.is_empty_space(target_) && map.get_body_at(target_) == null
		print(actor.get_name(), "  ", result)
		return result
	func get_cost(actor):
		return 50
	func use(actor):
		var map = actor.get_parent()
		map.move_actor(actor, target_)
		pass

class MeleeAttack:
	extends BaseAction
	var target_
	func _init(target).("melee_attack"):
		target_ = target
	func can_be_used(actor):
		return true
	func get_cost(actor):
		return 100
	func use(actor):
		print("HUE BACKSTAB")
		pass
