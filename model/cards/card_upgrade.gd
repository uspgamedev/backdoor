
extends "res://model/cards/card_entity.gd"

export(int) var bonus_amount = 2

func get_bonus_amount():
	return bonus_amount

func evoke(actor, options):
	actor.set_upgrade(self)
