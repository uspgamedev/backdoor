
extends Object

var pos
var node
var hp = 10
var damage = 0

func take_damage(amount):
	damage += amount
	if is_dead():
		pass

func is_dead():
	return damage >= hp
