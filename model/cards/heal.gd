
extends "res://model/card_skill.gd"

func can_be_evoked(actor):
	return true

func evoke(actor, options):
	actor.get_body().heal(5)
