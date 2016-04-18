
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
		return actor.get_node("/root/current/map")
	func can_be_used(actor):
		var map = get_map(actor)
		return map.is_empty_space(target_) && map.get_body_at(target_) == null
	func get_cost(actor):
		return 50
	func use(actor):
		var map = get_map(actor)
		map.move_actor(actor, target_)
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
		body_.take_damage(3)
