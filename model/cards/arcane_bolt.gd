
extends "res://model/card_ref.gd"

func valid_target(actor, target):
	var map = get_node("/root/sector/map")
	return map.get_body_at(target) != null

func get_time_cost():
	return 50

func get_options(actor):
	return [
		{ "type": "TARGET", "check": funcref(self, "valid_target") }
	]

func evoke(actor, options):
	var target = options[0]
	var map = get_node("/root/sector/map")
	var body = map.get_body_at(target)
	body.take_damage(5)
