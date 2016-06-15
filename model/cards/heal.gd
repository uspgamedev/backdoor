
extends "res://model/card_ref.gd"

func get_time_cost():
	return 20

func can_be_evoked(actor):
	return true

func get_description():
	return "This skill heals the player"

func evoke(actor, options):
	actor.get_body().heal(5)
