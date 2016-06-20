
extends "res://model/card_ref.gd"

export(int) var bonus_amount = 2

func get_bonus_amount():
	return bonus_amount

func evoke(actor, options):
	actor.set_upgrade(self)
