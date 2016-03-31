
extends Object

class BaseAction:
	var type_
	var arg_
	func _init(the_type, the_arg):
		type_ = the_type
		arg_ = the_arg
	func can_be_used(actor):
		pass
	func use(actor):
		pass

class Idle:
	extends BaseAction
	func _init().("idle", null):
		pass

class Move:
	extends BaseAction
	func _init(target).("move", target):
		pass
	func can_be_used(actor):
		return true
	func use(actor):
		var map = actor.get_node("..")
		map.move_actor(actor, arg_)
		pass
