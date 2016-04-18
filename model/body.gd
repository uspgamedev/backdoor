
extends Object

var type
var pos
var hp
var damage

func _init(the_type, the_pos, the_hp):
	type = the_type
	pos = the_pos
	hp = the_hp
	damage = 0

func take_damage(amount):
	damage += amount
	if is_dead():
		pass

func get_hp_percent():
	return 100*(hp - damage)/hp

func is_dead():
	return damage >= hp
