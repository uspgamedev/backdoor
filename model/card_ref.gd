
extends Node

class CARD_TYPE:
	const ARCANE = 0
	const ATHELITCS = 1
	const ENGINEERING = 2

export(int, "ARCANE", "ATHELITCS", "ENGINEERING") var card_type = 0

func get_card_type():
	return card_type

func get_time_cost():
	return 100

func can_be_evoked(actor):
	return true

func get_options(actor):
	return []

func get_description():
	return "A card"

func evoke(actor, options):
	print("Card evoked")
