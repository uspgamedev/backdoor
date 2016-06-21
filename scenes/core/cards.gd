
extends Node

const Card = preload("res://model/card_ref.gd")

func get_card_id(card):
	assert(card extends Card)
	for i in range(get_child_count()):
		if card == get_child(i):
			return i
	assert(false)
