
extends "res://model/card_ref.gd"

export(int, "WEAPON", "ARMORY", "ACCESSORY") var slot = 0

func get_slot():
	return slot