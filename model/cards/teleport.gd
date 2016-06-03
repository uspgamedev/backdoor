
extends "res://model/card_ref.gd"

func valid_target(actor, target):
	var map = get_node("/root/sector/map")
	return map.is_empty_space(target) and map.get_body_at(target) == null

func get_time_cost():
	return 50

func can_be_evoked(actor):
	return true

func get_options(actor):
	return [
		{ "type": "TARGET", "check": funcref(self, "valid_target") }
	]

func evoke(actor, options):
	var target = options[0]
	get_node("/root/sector/map").move_body(actor.get_body(), target)
