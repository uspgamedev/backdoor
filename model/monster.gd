
extends Node

export var body_hp = 10

func _ready():
	for card in get_node("cards").get_children():
		print(card.get_name())
