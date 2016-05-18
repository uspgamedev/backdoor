
extends Node

func get_card_id(card):
	for i in range(get_child_count()):
		if card == get_child(i):
			return i
	assert(false)
